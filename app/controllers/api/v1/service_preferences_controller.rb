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
		#byebug
		#@service_preference = ServicePreference.find(:conditions =>["app_user_id=? and service_name=?", params[:app_user_id], params[:service_name]])
		@service_preference = ServicePreference.find_by_app_user_id_and_service_name(params[:app_user_id], params[:service_name])
		if @service_preference.present?
			respond_to do |format|
      	if @service_preference.update(service_preference_params)
        	format.json { head :no_content, status: :true }
      	else
        	format.json { render json: @service_preference.errors, status: :false }
      	end
    	end
		else
			@service_preference = ServicePreference.new(service_preference_params) 
			#raise service_preference_params.inspect   
    	respond_to do |format|
      	if @service_preference.save
      		format.json { render json: @service_preference, status: :created }
        	format.xml { render xml: @service_preference, status: :created }
      	else
        	format.json { render json: @user.errors}
      	end
    	end
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
		params.permit(:app_user_id, :service_name, :service_provider, :contract_date, :is_contract, :contract_fee)
	end

end	