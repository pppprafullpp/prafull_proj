# encoding: utf-8
# lib/api.rb
require 'grape-entity'
module ServiceDeal
	class API < Grape::API
		prefix 'api'
		format :json
  	default_format :json

		resource :users do
			post do
				user = User.create(
						 	:name 													=> 		params[:name ],
						 	:email 													=> 		params[:email ],
						 	:password 											=> 		params[:password ],
						 	:password_confirmation 					=> 		params[:password_confirmation ],
						 	:role 													=> 		params[:role ],
						 	:enabled 												=> 		params[:enabled ],
				)
				if user.save
					{
						:success													=>		'true',
					}
				else
					{
						:success 													=> 		'false',
					}
				end	
			end	
		end

		resource :service_providers do
			get do
				#@service_provider = ServiceProvider.find_by_service_category_name(params[:service_category_name])
				@service_provider = ServiceProvider.where("service_category_name = ?", params[:service_category_name])
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
					@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id]).where("service_category_name = ?",params[:service_name]).take
					if @service_preference.present?
						{ 
					  	:success 												=> 		'true',
					    :service_name										=> 		@service_preference.service_category_name.to_s,
					    :service_provider 							=> 		@service_preference.service_provider_name.to_s,
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
				@deals = Deal.where(category: params[:service_name]).order("price ASC")
				if @deals.present?
					@deals.each do |sdeal|
					{
						:success    											=> 		'true',
						:category  												=> 		sdeal.category.to_s,
						:service_provider   							=>    sdeal.service_provider.to_s,
						:price     												=>    sdeal.price.to_s,
						:title  													=>  	sdeal.title.to_s,
						:url  														=> 		sdeal.url.to_s,
						:deal 														=>  	sdeal.deal.to_s,
						:short_description   							=>   	sdeal.short_description.to_s,
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