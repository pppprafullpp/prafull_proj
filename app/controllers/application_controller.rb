class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :null_session

	helper_method :decode_api_data,:get_providers_by_category, :get_zipcodes, :get_deal_rating

	before_filter do
		resource = controller_name.singularize.to_sym
		method = "#{resource}_params"
		params[resource] &&= send(method) if respond_to?(method, true)
		:cors_set_access_control_headers
	end

	def cors_set_access_control_headers
		headers['Access-Control-Allow-Origin'] = '*'
		headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
		headers['Access-Control-Request-Method'] = '*'
		headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
	end
	def verify_token
		puts "params="+params.to_yaml
		if params[:device_id].present? and params[:token].present?
			saved_token=DeviceRegister.find_by_device_id(params[:device_id]).token
			mobile_token=params[:token]
			if mobile_token!=params[:token]
				render :json=>{
							 message:"invalid token"
				}
			end
		else
			render :json=>{
				status:"token not issued"
			}
		end
	end
	def decode_api_data(data)
		if data.present?
			return Base64.decode64(data)
		else
			''
		end
	end

	def encode_api_data(data)
		return Base64.encode64(data)
	end

	def get_providers_by_category(category_name)
		 	service_category = ServiceCategory.where("name LIKE '%#{category_name}%'").first
			providers = ServiceProvider.where(:service_category_id => service_category.id).pluck(:name, :id)
			providers
	end

	def get_zipcodes
		zipcodes = Rails.cache.fetch(:expire_in => 24.hours) do
			Zipcode.all.map { |r| [r.code+' - '+r.city, r.id] }
		end
		return zipcodes
	end
	def get_deal_rating(deal_id,app_user_id)
		response = JSON.parse(URI.parse("http://localhost:3000/api/v1/comment_ratings?deal_id=#{deal_id}&app_user_id=#{app_user_id}").read)
		response
	end
end
