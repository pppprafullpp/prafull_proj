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
		#byebug
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
			render :status => 200,
						 :json => {
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
			render :status => 200,
						 :json => {
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
			render :status => 200,
						 :json => { :success => true }
		else
			render :status => 401,
						 :json => { :success => false }
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
	def service_preference_params
		params.permit(:app_user_id, :service_category_id, :service_provider_id, :service_category_name, :service_provider_name, :is_contract, :start_date, :end_date, :price, :plan_name)
	end
	def internet_service_preference_params
		params.permit(:service_preference_id, :upload_speed, :download_speed, :data, :email, :online_storage, :wifi_hotspot)
	end
	def cable_service_preference_params
		params.permit(:service_preference_id, :free_channels, :premium_channels)
	end
	def telephone_service_preference_params
    params.permit(:service_preference_id, :call_minutes, :text_messages, :talk_unlimited, :text_unlimited)
  end
  def cellphone_service_preference_params
    params.permit(:service_preference_id, :call_minutes, :text_messages, :talk_unlimited, :text_unlimited, :data_plan, :data_speed)
  end
  def bundle_service_preference_params
    params.permit(:service_preference_id, :upload_speed, :download_speed, :data, :free_channels, :premium_channels, :call_minutes, :text_messages, :talk_unlimited, :text_unlimited, :data_plan, :data_speed)
  end

end	