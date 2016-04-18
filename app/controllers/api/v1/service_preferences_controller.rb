class Api::V1::ServicePreferencesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@service_preferences = ServicePreference.all
	end
	def new
		@service_preference = ServicePreference.new
		#@service_preference.build_internet_service_preference
	end

	def create
		#@service_preference = ServicePreference.find(:conditions =>["app_user_id=? and service_name=?", params[:app_user_id], params[:service_name]])
		#@service_preference = ServicePreference.find_by_app_user_id_and_service_category_id(params[:app_user_id], params[:category]).take
		@service_preference = ServicePreference.where("app_user_id = ? AND service_category_id = ?", params[:app_user_id], params[:service_category_id]).take
		if @service_preference.present?
			if params[:service_category_id] == '1'
				@service_preference.internet_service_preference.update(internet_service_preference_params)
			elsif params[:service_category_id] == '2'
				@service_preference.telephone_service_preference.update(telephone_service_preference_params)
			elsif params[:service_category_id] == '3'
				@service_preference.cable_service_preference.update(cable_service_preference_params)
			elsif params[:service_category_id] == '4'
				@service_preference.cellphone_service_preference.update(cellphone_service_preference_params)	
			elsif params[:service_category_id] == '5'
				@service_preference.bundle_service_preference.update(bundle_service_preference_params)
			elsif params[:service_category_id] == '8'
				@service_preference.update(service_preference_params)	
			end	
      if @service_preference.update(service_preference_params)
      	if params[:is_contract] == "true"
        	send_notification_no_contract
        elsif params[:is_contract] == "false"	
        		send_notification_is_contract	
		end
        	render :status => 200,
              	 :json => { :success => true }
      else
        	render :status => 401,
           		:json => { :success => false }	
      end
		else
			@service_preference = ServicePreference.new(service_preference_params) 
			@service_preference.save!
			if params[:service_category_id] == '1'
				@internet_service_preference = InternetServicePreference.new(internet_service_preference_params)
				@internet_service_preference.service_preference_id = @service_preference.id
				@internet_service_preference.save!
			elsif params[:service_category_id] == '2'	
				@internet_service_preference = TelephoneServicePreference.new(telephone_service_preference_params)
				@internet_service_preference.service_preference_id = @service_preference.id
				@internet_service_preference.save!	
			elsif params[:service_category_id] == '3'	
				@internet_service_preference = CableServicePreference.new(cable_service_preference_params)
				@internet_service_preference.service_preference_id = @service_preference.id
				@internet_service_preference.save!
			elsif params[:service_category_id] == '4'	
				@internet_service_preference = CellphoneServicePreference.new(cellphone_service_preference_params)
				@internet_service_preference.service_preference_id = @service_preference.id
				@internet_service_preference.save!	
			elsif params[:service_category_id] == '5'	
				@internet_service_preference = BundleServicePreference.new(bundle_service_preference_params)
				@internet_service_preference.service_preference_id = @service_preference.id
				@internet_service_preference.save!	
			elsif params[:service_category_id] == '8'	
				@internet_service_preference = @service_preference
				@internet_service_preference.save!	
				#@internet_service_preference = BundleServicePreference.new(bundle_service_preference_params)
				#@internet_service_preference.service_preference_id = @service_preference.id
				#@internet_service_preference.save!	
			end
      if @service_preference.save && @internet_service_preference.save #|| (@service_preference.save && @cable_service_preference.save)
        	if params[:is_contract] == "true"
        		send_notification_no_contract
        	elsif params[:is_contract] == "false"	
        		send_notification_is_contract
					end
					render :status => 200,
              	 :json => { :success => true }
      else
        	render :status => 401,
           		:json => { :success => false }
      end
    end
	end

	def get_service_preferences
		@service_preferences = ServicePreference.where(app_user_id: params[:app_user_id]).order("created_at DESC")
		if @service_preferences.present?
			render :status => 200,:json => {
				:success => true,
				:service_preferences => @service_preferences.as_json(:except => [:service_category_name, :service_provider_name, :created_at, :updated_at])
			}
		else
			render :json => { :success => false }
		end	
	end

	def fetch_service_preferences
		@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id]).where("service_category_id = ?",params[:category]).take
		if @service_preference.present?	
			if params[:category] == '1'
				@internet_preference = InternetServicePreference.where("service_preference_id = ?", @service_preference.id ).take
			elsif params[:category] == '2'
				@internet_preference = TelephoneServicePreference.where("service_preference_id = ?", @service_preference.id ).take				
			elsif params[:category] == '3'
				@internet_preference = CableServicePreference.where("service_preference_id = ?", @service_preference.id ).take
			elsif params[:category] == '4'
				@internet_preference = CellphoneServicePreference.where("service_preference_id = ?", @service_preference.id ).take
			elsif params[:category] == '5'
				@internet_preference = BundleServicePreference.where("service_preference_id = ?", @service_preference.id ).take
			elsif params[:category] == '8'
				@internet_preference = @service_preference #ServicePreference.where("service_preference_id = ?", @service_preference.id ).take
			end
		end
		if @service_preference.present? && @internet_preference.present?
			json_1 = @service_preference.as_json(:except => [:service_category_name, :service_provider_name, :created_at, :updated_at])
			json_2 = @internet_preference.as_json(:except => [:service_preference_id, :created_at, :updated_at])
			@user_preference = json_1.reverse_merge!(json_2)
			render :status => 200,:json => {
				:success => true,
				#:service_preference => @service_preference.as_json(:except => [:service_category_name, :service_provider_name, :created_at, :updated_at])
				:service_preference => @user_preference
			}
		else
			render :json => { :success => false }
		end	
	end

	def deselect_service_preference
		@service_preference = ServicePreference.where("app_user_id = ? AND service_category_id = ?", params[:app_user_id], params[:category]).first
		if @service_preference.present?
			@service_preference.destroy
			render :status => 200, :json => { :success => true }
		else
			render :status => 401, :json => { :success => false }
		end	
	end

	def edit
		@service_preference = ServicePreference.find_by_app_user_id(params[:app_user_id])
	end

	#def update
	#	@service_preference = ServicePreference.find_by_app_user_id(params[:app_user_id])
	#	respond_to do |format|
    #    		if @service_preference.update(service_preference_params)
    #      		format.json { head :no_content, status: :true }
    #    		else
    #      		format.json { render json: @service_preference.errors, status: :false }
    #    		end
    #  	end
	#end

	private
	def send_notification_is_contract
		@app_user = AppUser.find_by_id(params[:app_user_id])
		@app_user_device = @app_user.device_flag
		@state = @app_user.state
		@current_plan_price = params[:price]
		@user_notification_day = @app_user.notification.day
		@user_contract_end_date = params[:end_date]
		if @user_contract_end_date.present? && @user_notification_day.present?
			if params[:service_category_id] == "1"
				@current_d_speed = params[:download_speed]
				@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND download_speed = ?", true, @state, params[:service_category_id], @current_d_speed).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND download_speed > ?", true, @state, params[:service_category_id], @current_d_speed).order("price ASC").limit(2)
			elsif params[:service_category_id] == "2"	
				if params[:domestic_call_unlimited] == "true"
					@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ?", true, @state, params[:service_category_id], true).order("price ASC")
					@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND price > ?", true, @state, params[:service_category_id], false, @current_plan_price).order("price ASC").limit(2)
				else
					@current_c_minutes = params[:domestic_call_minutes]
					@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND price <= ?", true, @state, params[:service_category_id], true, @current_c_minutes).order("price ASC")
					@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND domestic_call_minutes > ?", true, @state, params[:service_category_id], false, @current_c_minutes).order("price ASC").limit(2)
				end
			elsif params[:service_category_id] == "3"
				@current_f_channels = params[:free_channels]
				@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND free_channels = ?", true, @state, params[:service_category_id], @current_f_channels).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND free_channels > ?", true, @state, params[:service_category_id], @current_f_channels).order("price ASC").limit(2)
			elsif params[:service_category_id] == "4"	
				if params[:domestic_call_unlimited] == "true"
					@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ?", true, @state, params[:service_category_id], true).order("price ASC")
					@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND price > ?", true, @state, params[:service_category_id], false, @current_plan_price).order("price ASC").limit(2)
				else
					@current_c_minutes = params[:domestic_call_minutes]
					@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND price <= ?", true, @state, params[:service_category_id], true, @current_c_minutes).order("price ASC")
					@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND domestic_call_minutes > ?", true, @state, params[:service_category_id], false, @current_c_minutes).order("price ASC").limit(2)
				end	
			elsif params[:service_category_id] == "5"
				@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ?", true, @state, params[:service_category_id]).order("price ASC").limit(5)	
			end	
			if @equal_deals.present? && @greater_deals.present?
				@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
			elsif @equal_deals.present? && @greater_deals.blank?
				@merged_deals = (@equal_deals).sort_by(&:price)
			elsif @equal_deals.blank? && @greater_deals.present?
				@merged_deals = (@greater_deals).sort_by(&:price)
			end
			if @merged_deals.present?
				@b_deal = @merged_deals.first
			end
			
			if @b_deal.present?	
		      	@remaining_days = (@user_contract_end_date.to_datetime - DateTime.now).to_i
		      	if @remaining_days < @user_notification_day
		      		if @app_user_device == "android"
		      			gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
								registration_id = ["#{@app_user.gcm_id}"]
		      			gcm.send(registration_id, {data: {message: "Price : "+"#{@b_deal.price}" + "\n" + "Short Description : "+"#{@b_deal.short_description}"}})
		      		elsif @app_user_device == "iphone"
		      			pusher = Grocer.pusher(
		        			certificate: "#{Rails.root}/public/certificates/dev_certificate.pem",      	# required
		        			passphrase:  "1234",                       																	# optional
		        			gateway:     "gateway.sandbox.push.apple.com",                      				# optional; See note below.
		        			port:        2195,                       																		# optional
		        			retries:     3                           																		# optional
		      			)
		      			notification = Grocer::Notification.new(
		        			device_token:      "#{@app_user.gcm_id}",
		        			alert:             "Price : "+"#{@b_deal.price}" + "\n" + "Short Description : "+"#{@b_deal.short_description}",
		        			badge:             42
		        			#category:          "a category",         																	# optional; used for custom notification actions
		        			#sound:             "siren.aiff",         																	# optional
		        			#expiry:            Time.now + 60*60,     																	# optional; 0 is default, meaning the message is not stored
		        			#identifier:        1234,                 																	# optional; must be an integer
		        			#content_available: true                  																	# optional; any truthy value will set 'content-available' to 1
		      			)
		      			pusher.push(notification)
		      		end    		
				end
		    end
    	end
	end
	def send_notification_no_contract
		@app_user = AppUser.find_by_id(params[:app_user_id])
		@app_user_device = @app_user.device_flag
		@state = @app_user.state
		@current_plan_price = params[:price]
		if params[:service_category_id] == "1"
			@current_d_speed = params[:download_speed]
			@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
			@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
		elsif params[:service_category_id] == "2"	
			if params[:domestic_call_unlimited] == "true"
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND service_category_id = ? AND price > ?", true, params[:service_category_id], @current_plan_price).order("price ASC").limit(2)
			else
				@current_c_minutes = params[:domestic_call_minutes]
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ? AND price <= ?", true, params[:service_category_id], @current_plan_price).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
			end
		elsif params[:service_category_id] == "3"
			@current_f_channels = params[:free_channels]
			@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
			@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
		elsif params[:service_category_id] == "4"	
			if params[:domestic_call_unlimited] == "true"
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND service_category_id = ? AND price > ?", true, params[:service_category_id], @current_plan_price).order("price ASC").limit(2)
			else
				@current_c_minutes = params[:domestic_call_minutes]
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ? AND price <= ?", true, params[:service_category_id], @current_plan_price).order("price ASC")
				@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
			end	
		elsif params[:service_category_id] == "5"
			@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(5)	
		end	
		if @equal_deals.present? && @greater_deals.present?
			@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
		elsif @equal_deals.present? && @greater_deals.blank?
			@merged_deals = (@equal_deals).sort_by(&:price)
		elsif @equal_deals.blank? && @greater_deals.present?
			@merged_deals = (@greater_deals).sort_by(&:price)
		end
		if @merged_deals.present?
			@b_deal = @merged_deals.first
		end
		
		if @b_deal.present?
			if @app_user_device == "android"
				gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
    		registration_id = ["#{@app_user.gcm_id}"]
    		gcm.send(registration_id, {data: {message: "Price : "+"#{@b_deal.price}" + "\n" + "Short Description : "+"#{@b_deal.short_description}"}})
			elsif @app_user_device == "iphone"
				pusher = Grocer.pusher(
        	certificate: "#{Rails.root}/public/certificates/dev_certificate.pem",      	# required
        	passphrase:  "1234",                       																	# optional
        	gateway:     "gateway.sandbox.push.apple.com",                      		# optional; See note below.
        	port:        2195,                       																		# optional
        	retries:     3                           																		# optional
      	)
      	notification = Grocer::Notification.new(
        	device_token:      "#{@app_user.gcm_id}",
        	alert:             "Price : "+"#{@b_deal.price}" + "\n" + "Short Description : "+"#{@b_deal.short_description}",
        	badge:             42
        	#category:          "a category",         																	# optional; used for custom notification actions
        	#sound:             "siren.aiff",         																	# optional
        	#expiry:            Time.now + 60*60,     																	# optional; 0 is default, meaning the message is not stored
        	#identifier:        1234,                 																	# optional; must be an integer
        	#content_available: true                  																	# optional; any truthy value will set 'content-available' to 1
      	)
      	pusher.push(notification)
			end	
		end
  	end
	def service_preference_params
		if params[:start_date].present? && params[:end_date].present?
			begin
				params[:start_date] = Date.strptime(params[:start_date].to_s.strip, "%m/%d/%Y").strftime("%d/%m/%Y")
				params[:end_date] = Date.strptime(params[:end_date].to_s.strip, "%m/%d/%Y").strftime("%d/%m/%Y")
			rescue
				params[:start_date] = Date.strptime(params[:start_date].to_s.strip, "%d/%m/%Y").strftime("%d/%m/%Y")
				params[:end_date] = Date.strptime(params[:end_date].to_s.strip, "%d/%m/%Y").strftime("%d/%m/%Y")
			end
		end
		params.permit(:app_user_id, :service_category_id, :service_provider_id, :service_category_name, :service_provider_name, :is_contract, :start_date, :end_date, :price, :plan_name)
	end
	def internet_service_preference_params
		params.permit(:service_preference_id, :upload_speed, :download_speed, :data, :email, :online_storage, :wifi_hotspot)
	end
	def cable_service_preference_params
		params.permit(:service_preference_id, :free_channels, :premium_channels)
	end
	def telephone_service_preference_params
    params.permit(:service_preference_id, :domestic_call_minutes, :international_call_minutes, :domestic_call_unlimited, :international_call_unlimited)
  end
  def cellphone_service_preference_params
    params.permit(:service_preference_id, :domestic_call_minutes, :international_call_minutes, :domestic_call_unlimited, :international_call_unlimited, :data_plan, :data_speed)
  end
  def bundle_service_preference_params
    params.permit(:service_preference_id, :upload_speed, :download_speed, :data, :free_channels, :premium_channels, :domestic_call_minutes, :international_call_minutes, :domestic_call_unlimited, :international_call_unlimited, :data_plan, :data_speed, :bundle_combo)
  end

end	