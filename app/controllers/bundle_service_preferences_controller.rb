class BundleServicePreferencesController < ApplicationController
	
	def index
		@bundle_service_preferences = BundleServicePreference.all
	end

  def edit
    @bundle_service_preference = BundleServicePreference.find(params[:id])
  end

  def update
    @bundle_service_preference = BundleServicePreference.find(params[:id])
    respond_to do |format|
      if @bundle_service_preference.update(bundle_service_preference_params)
        format.html { redirect_to bundle_service_preferences_path, notice: 'Successfully updated.' }
        format.xml  { render :xml => @bundle_service_preference, :status => :created, :bundle_service_preference => @bundle_service_preference }
      else
        format.html { render :edit }
        format.json { render json: @bundle_service_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
      @bundle_service_preference = BundleServicePreference.find(params[:id])
      respond_to do |format|
          if @bundle_service_preference.destroy
            format.html { redirect_to bundle_service_preferences_path, :notice => 'You have successfully removed a service preference' }
            format.xml  { render :xml => @bundle_service_preference, :status => :created, :bundle_service_preference => @bundle_service_preference }
          end
      end
  end

  private
  def bundle_service_preference_params
    params.require(:bundle_service_preference).permit(:service_preference_id, :upload_speed, :download_speed, :data, :free_channels, :premium_channels, :domestic_call_minutes, :international_call_minutes, :domestic_call_unlimited, :international_call_unlimited, :data_plan, :data_speed, :bundle_combo)
  end
end 