class ApplicationController < ActionController::Base

	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :null_session

	helper_method :calculate_offer_price,:display_logo_permission,:decode_api_data,:get_providers_by_category, :get_zipcodes, :get_deal_rating, :get_category_name_by_category_id, :display_deal_name_permission

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

	def calculate_offer_price(price_monthly,contract_period)
		offer_price = ( "%.2f" %  (price_monthly * contract_period)).to_s 
	end

	def display_logo_permission(provider_id,deal_type)
		if ServiceDealConfig::where(config_key: "show_deals_logo").first.config_value == ServiceDealConfig::SHOW_DEAL_LOGO
			if ([1,3,6,12,30].include? provider_id) && (deal_type == "business")
				url ="http://res.cloudinary.com/servicedealz/image/upload/v1479289687/at_t_yltr81.png"
			# elsif [2, 5, 15, 43].include? provider_id
			# 	url = "http://res.cloudinary.com/servicedealz/image/upload/v1479289565/twc_vertical_3_z2smld.png"
			# elsif [7, 24, 48, 107].include? provider_id
			# 	url = "http://res.cloudinary.com/servicedealz/image/upload/v1479289775/Spectrum_1_mpwznq.png"
			# elsif [10, 47, 61, 112, 113].include? provider_id
			# 	url = "http://res.cloudinary.com/servicedealz/image/upload/v1478696145/cox_w01xck.png"
			else
				false
			end
		else
			

			if ([1,3,6,12,30].include? provider_id) && (deal_type == "residence")
				# url = "http://res.cloudinary.com/servicedealz/image/upload/v1477049177/default_logo_uak2tg.png"
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159471/coming-soonv1_faxwxg.png"
			elsif [2, 5, 15, 43].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159471/coming-soonv1_faxwxg.png"
			elsif [4,41,18, 39, 50, 90].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159475/coming-soonv2_fhbxin.png"
			elsif [7, 24, 48, 107,10, 47, 61, 112, 113,34,109, 110, 111].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159497/coming-soonv6_s9bnmj.png" 
			elsif [11].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159491/coming-soonv5_cklj4p.png" 
			elsif [17].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159479/coming-soonv3_moopcw.png"

			elsif [28, 55].include? provider_id
				url ="http://res.cloudinary.com/servicedealz/image/upload/v1478159526/coming-soonv11_stfc0n.png"
			elsif [29, 49, 54].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159487/coming-soonv4_ac3qrs.png"
			elsif [19,21,20,45,22,23,51,91,25,52,26,27,31,32,33,35,37,38,40,42,95,44,85,53,63,82,88,89,101,102, 103, 104, 105, 106,108,114].include? provider_id
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159445/coming-soon_global_csi91h.png"
			elsif ([1,3,6,12,30].include? provider_id) && (deal_type == "business")
				url ="http://res.cloudinary.com/servicedealz/image/upload/v1477049217/att_v_z4ulpm.png"
			# elsif (![1,3,6,12,30].include? provider_id) && (deal_type == "business")
			# 	url = "http://res.cloudinary.com/servicedealz/image/upload/v1477049177/default_logo_uak2tg.png"
			else
				url = "http://res.cloudinary.com/servicedealz/image/upload/v1478159445/coming-soon_global_csi91h.png"
			end
		end
	end

	def display_deal_name_permission(provider_id,deal_type,title)
		if ServiceDealConfig::where(config_key: "show_deals_name").first.config_value== ServiceDealConfig::SHOW_DEAL_NAME
			# if ([1,3,6,12,30].include? provider_id) && (deal_type == "business")
				name = title
			# else
			# 	name =''
			# end
		else 
			if ([1,3,6,12,30].include? provider_id) && (deal_type == "business")
				name = title
			elsif ([2, 5, 15, 43].include? provider_id) && (deal_type == "residence")
				name = title
			elsif ([7, 24, 48, 107].include? provider_id) && (deal_type == "residence")
				name = title
			elsif ([10, 47, 61, 112, 113].include? provider_id) && (deal_type == "residence")
				name = title
			else 
				name = ''
			end
		end
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
	

end
