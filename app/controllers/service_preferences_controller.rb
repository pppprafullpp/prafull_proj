class ServicePreferencesController < ApplicationController
	
	def index
		@service_preferences = ServicePreference.all
	end

	def new
		@service_preference = ServicePreference.new
	end

  def edit
    @service_preference = ServicePreference.find(params[:id])
  end

	def create
		@service_preference = ServicePreference.new(service_preference_params)   
    #raise @service_preference.inspect 
    	respond_to do |format|
      		if @service_preference.save
        		format.html { redirect_to service_preferences_path, :notice => 'You have successfully created a service preference' }
        		format.xml  { render :xml => @service_preference, :status => :created, :service_preference => @service_preference }
      		else
        		format.html { render :action => "new" }
        		format.xml  { render :xml => @service_preference.errors, :status => :unprocessable_entity }
      		end
    	end
	end

  def update
    @service_preference = ServicePreference.find(params[:id])
      respond_to do |format|
          if @service_preference.update(service_preference_params)
            format.html { redirect_to service_preferences_path, notice: 'You have successfully updated a Service Preference.' }
            format.xml  { render :xml => @service_preference, :status => :created, :service_preference => @service_preference }
          else
            format.html { render :edit }
            format.json { render json: @service_preference.errors, status: :unprocessable_entity }
          end
      end
  end

	def destroy
    	@service_preference = ServicePreference.find(params[:id])
    	respond_to do |format|
          if @service_preference.destroy
            format.html { redirect_to service_preferences_path, :notice => 'You have successfully removed a service preference' }
            format.xml  { render :xml => @service_preference, :status => :created, :service_preference => @service_preference }
          end
    	end
  	end

	private
	def service_preference_params
		params.require(:service_preference).permit(:app_user_id, :service_category_name, :service_provider_name, :contract_date, :is_contract, :contract_fee)
	end
end	