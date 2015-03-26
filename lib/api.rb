# encoding: utf-8
# lib/api.rb
require 'grape-entity'
module ServiceDeal
	class API < Grape::API
		prefix 'api'
		format :json
  	default_format :json

		resource :service_providers do
			get do
				#@service_provider = ServiceProvider.find_by_service_category_name(params[:service_category_name])
				@service_provider = ServiceProvider.where("is_active = ?", true).where("service_category_id = ?", params[:category])
				if @service_provider.present?
					@service_provider.each do |service_provider|
						{
							:success  											=>    'true',
						}
					end	
				else
					{
						:success                          => 		'false',
					}
				end	
			end	
		end	

		resource :fetch_service_category do
			get do
				@service_category = ServiceCategory.all
				@service_category.each do |sc|
					{
						:success => 'true',
						:service_id => sc.id,
						:service_name => sc.name,
					}
				end	
			end	
		end	

		resource :app_users do
			post do
				@app_user = AppUser.create(
							:first_name 										=> 		params[:first_name],
							:last_name 											=> 		params[:last_name],
							:email 													=> 		params[:email],
							:password 											=> 		params[:password],
							:address                        =>    params[:address],
							:state 													=> 		params[:state],
							:city 													=> 		params[:city],
							:zip 														=> 		params[:zip],
							:active                         =>    params[:active],
							:avatar                         =>    params[:avatar],
				)
				if @app_user.save
					{ 
					  	:success 												=> 		'true',
					  	:app_user_id   									=> 		@app_user.id,
							:first_name 										=> 		@app_user.first_name, 
					    :last_name 											=> 		@app_user.last_name,
					    :email 													=> 		@app_user.email,
					    :address   										  =>    @app_user.address,
					    :state 													=> 		@app_user.state,
					    :city 													=> 		@app_user.city,
					    :zip  													=> 		@app_user.zip,
					    :active                         =>    @app_user.active,
					    :avatar                         =>    @app_user.avatar,
					}
				else
					{
							:success 												=>  	'false',
					}
				end
			end	
			get do
				@app_user = AppUser.find_by_id(params[:id])
				if @app_user.present?
					{
						  :success 												=> 		'true',
						  :first_name 										=> 		@app_user.first_name.to_s, 
					    :last_name 											=> 		@app_user.last_name.to_s,
					    :email 													=> 		@app_user.email.to_s,
					    :address     										=>    @app_user.address.to_s,
					    :state 													=> 		@app_user.state.to_s,
					    :city 													=> 		@app_user.city.to_s,
					    :zip  													=> 		@app_user.zip.to_s,
					    :active                         =>    @app_user.active.to_s,
					    :avatar                         =>    @app_user.avatar.to_s,
					}
				else
					{
							:success 												=>  	'false',
					}
				end
			end	
		end

		resource :service_preferences do
				post do
					@service_preference = ServicePreference.create(
						  :app_user_id										=>		params[:app_user_id],
							:service_name 									=> 		params[:service_name],
							:service_provider 							=> 		params[:service_provider],
							:contract_date 									=> 		params[:contract_date],
							:is_contract 										=> 		params[:is_contract],
							:contract_fee 									=> 		params[:contract_fee],
					)
					if @service_preference.save
						{ 
					  	:success 								  			=> 		'true',
						}
					else
						{
							:success 												=>  	'false',
						}
					end
				end	
				get do
					@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id]).where("service_category_id = ?",params[:category]).take
					if @service_preference.present?
						{ 
					  	:success 												=> 		'true',
					    :service_category								=> 		@service_preference.service_category_id.to_s,
					    :service_provider 							=> 		@service_preference.service_provider_id.to_s,
					    :contract_date 									=> 		@service_preference.contract_date.to_s,
					    :is_contract										=> 		@service_preference.is_contract.to_s,
					    :contract_fee  									=> 		@service_preference.contract_fee.to_s,
						}
					else
						{
							:success 												=>		'false',
						}
					end	
				end	
				put do
					@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id]).where("service_name = ?", params[:service_name])
					if @service_preference.present? 
    				@service_preference.update_attributes(params.permit(:service_provider, :contract_date, :is_contract, :contract_fee))
  				else
    				{
    					 :success => 'false',
    				}
  				end
				end	
		end	

		resource :deals do
			get do
				if params[:zip_code].present? && params[:category].blank?
					@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).order("price ASC")
				elsif params[:category].present? && params[:zip_code].blank?
					@deals = Deal.where("is_active = ?", true).where(service_category_id: params[:category]).order("price ASC")
				elsif params[:zip_code].present? && params[:category].present?  
				  @deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).where(service_category_id: params[:category]).order("price ASC")
				end
				if @deals.present?
					@deals.each do |sdeal|
					{
						:success    					            => 	  'true',
						:service_category  				        => 	  sdeal.service_category_name.to_s,
						:service_provider   			        =>    sdeal.service_provider_name.to_s,
						:title  						              =>  	sdeal.title.to_s,
						:url  							              => 	  sdeal.url.to_s,
						:price     						            =>    sdeal.price.to_s,
						:state                            =>    sdeal.state.to_s,
						:city                             =>    sdeal.city.to_s,
						:zip                              =>    sdeal.zip.to_s,
						:short_description   			        =>   	sdeal.short_description.to_s,
						:detail_description 			        =>  	sdeal.detail_description.to_s,
						:you_save_text                    =>    sdeal.you_save_text.to_s,
						:start_date                       =>    sdeal.start_date.to_s,
						:end_date                         =>    sdeal.end_date.to_s,
						:active                           =>    sdeal.is_active.to_s,
					}
				  end
				else
					{
						:success  												=> 		'false',
					}
				end
			end	
		end

		resource :service_preference_info do
			get do
				@service_preference = ServicePreference.where(app_user_id: params[:app_user_id])
				if @service_preference.present?
					@service_preference.each do |service_preference|
					 	{
							:success                           =>   'true',
						}
				  end
				else
					{
						:success                           =>    'false',
					}
				end
			end	
		end	

		resource :notifications do	
			get do
				@notification = Notification.find_by_app_user_id(params[:app_user_id])
						if @notification.present?
							{ 
						  	:success 																=> 		'true',
						    :app_user_id														=> 		@notification.app_user_id.to_s,
						    :recieve_notification 							    => 		@notification.recieve_notification.to_s,
					  	  :day          													=> 		@notification.day.to_s,
							}
						else
							{
								:success 												        =>		'false',
							}
						end
			end				
		end

		resource :get_app_user_info do
			get do
				@app_user = AppUser.find_by_email(params[:email])
				if @app_user.present?
					{
						    :success      													=>    'true',
						    :app_user_id    												=>    @app_user.id.to_s,
							  :first_name 										        => 		@app_user.first_name.to_s, 
					      :last_name 											        => 		@app_user.last_name.to_s,
					      :email 													        => 		@app_user.email.to_s,
					      :address    														=>    @app_user.address.to_s,
					      :state 													        => 		@app_user.state.to_s,
					      :city 													        => 		@app_user.city.to_s,
					      :zip  													        => 		@app_user.zip.to_s,
					      :active                                 =>    @app_user.active.to_s,
					      :avatar                                 =>    @app_user.avatar.to_s,

					}
				else
					{
						:success    																=>    'false',
					}
				end
			end	
		end	
	end
end	