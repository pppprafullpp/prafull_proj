class Api::V1::ServicePreferencesController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@service_preferences = ServicePreference.all
	end
	def new
		@service_preference = ServicePreference.new
	end

	def create
		#@service_preference = ServicePreference.find(:conditions =>["app_user_id=? and service_name=?", params[:app_user_id], params[:service_name]])
		#@service_preference = ServicePreference.find_by_app_user_id_and_service_category_id(params[:app_user_id], params[:category]).take
		@service_preference = ServicePreference.where("app_user_id = ? AND service_category_id = ?", params[:app_user_id], params[:service_category_id]).take
		if @service_preference.present?
      		if @service_preference.update(service_preference_params)
        		render :status => 200,
           		:json => { :success => true }
      		else
        		render :status => 401,
           		:json => { :success => false }	
        	end
		else
			@service_preference = ServicePreference.new(service_preference_params) 
      		if @service_preference.save
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
			render :status => 200,
						 :json => {
						 						:success => true,
						 						:service_preference => @service_preference.as_json(:except => [:service_category_name, :service_provider_name, :created_at, :updated_at])
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
		params.permit(:app_user_id, :service_category_id, :service_provider_id, :service_category_name, :service_provider_name, :contract_date, :is_contract, :contract_fee)
	end

end	