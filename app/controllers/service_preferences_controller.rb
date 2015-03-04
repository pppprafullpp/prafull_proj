class ServicePreferencesController < ApplicationController
	def index
		@service_preferences = ServicePreference.all
	end
	def new
		@service_preference = ServicePreference.new
	end
	def create
		@service_preference = ServicePreference.new(service_preference_params)    
    respond_to do |format|
      if @service_preference.save
        format.html { redirect_to app_users_service_preferences_path, :notice => 'You have successfully created a service preference' }
        format.xml  { render :xml => @service_preference, :status => :created, :service_preference => @service_preference }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_preference.errors, :status => :unprocessable_entity }
      end
    end
	end

	private
	def service_preference_params
		params.require(:app_users_service_preference).permit(:app_user_id, :service_name, :service_provider, :contract_date, :is_contract, :contract_fee)
	end
end	