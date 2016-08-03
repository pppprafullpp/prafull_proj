class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :null_session

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
		if params[:device_id].present? and params[:token].present?
			 saved_token=DeviceRegister.find_by_device_id(params[:device_id]).token
				render :json=>{
					message:"invalid token"
					} if saved_token!=params[:token]
		end
	end
	def decode_api_data(data)
		return Base64.decode64(data)
	end
	
	def encode_api_data(data)
		return Base64.encode64(data)
	end
end
