class BundleServicePreferencesController < ApplicationController
	
	def index
		@bundle_service_preferences = BundleServicePreference.all
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
    params.require(:cable_service_preference).permit(:service_preference_id, :upload_speed, :download_speed, :data, :free_channels, :premium_channels, :call_minutes, :text_messages, :talk_unlimited, :text_unlimited, :data_plan, :data_speed)
  end
end 