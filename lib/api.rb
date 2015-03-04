# encoding: utf-8
# lib/api.rb
module ServiceDeal
	class API < Grape::API
		prefix 'api'
		format :json
  	default_format :json

		resource :users do
			post do
				user = User.create(
						 	:name 									=> 		params[:name ],
						 	:email 									=> 		params[:email ],
						 	:password 							=> 		params[:password ],
						 	:password_confirmation 	=> 		params[:password_confirmation ],
						 	:role 									=> 		params[:role ],
						 	:enabled 								=> 		params[:enabled ],
				)
				if user.save
					{
						:success								=>		'true',
					}
				else
					{
						:success 								=> 		'false',
					}
				end	
			end	
		end	
		resource :app_users do
			post do
				@app_user = AppUser.create(
							:first_name 						=> 		params[:first_name],
							:last_name 							=> 		params[:last_name],
							:email 									=> 		params[:email],
							:password 							=> 		params[:password],
							:state 									=> 		params[:state],
							:city 									=> 		params[:city],
							:zip 										=> 		params[:zip],
				)
				if @app_user.save
					{ 
					  	:success 								=> 		'true',
							:first_name 						=> 		@app_user.first_name, 
					    :last_name 							=> 		@app_user.last_name,
					    :email 									=> 		@app_user.email,
					    :state 									=> 		@app_user.state,
					    :city 									=> 		@app_user.city,
					    :zip  									=> 		@app_user.zip,
					}
				else
					{
							:success 								=>  	'false',
					}
				end
			end	
			get do
				@app_user = AppUser.find_by_id(params[:id])
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
					@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id]).where("service_name = ?",params[:service_name])
					byebug
					if @service_preference.present?
						{ 
					  	:success 												=> 		'true',
					    :service_name										=> 		@service_preference.service_name,
					    :service_provider 							=> 		@service_preference.service_provider,
					    :contract_date 									=> 		@service_preference.contract_date,
					    :is_contract										=> 		@service_preference.is_contract,
					    :contract_fee  									=> 		@service_preference.contract_fee,
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
						byebug 
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
				Deal.all
			end	
		end	
	end
end	