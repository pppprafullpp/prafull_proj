# encoding: utf-8
# lib/api.rb
module ServiceDeal
	class API < Grape::API
		prefix 'api'
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
					}.to_json
				else
					user.errors.to_json
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
					}.to_json
				else
					{
							:success 								=>  	'false',
					}.to_json
				end
			end	
			get do
				AppUser.all
			end	
		end

		resource :deals do
			get do
				Deal.all
			end	
		end	
	end
end	