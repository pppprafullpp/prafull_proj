class TelephoneServicePreferencesController < ApplicationController
	
	def index
		@telephone_service_preferences = TelephoneServicePreference.all
	end

  def destroy
      @telephone_service_preference = TelephoneServicePreference.find(params[:id])
      respond_to do |format|
          if @telephone_service_preference.destroy
            format.html { redirect_to telephone_service_preferences_path, :notice => 'You have successfully removed a service preference' }
            format.xml  { render :xml => @telephone_service_preference, :status => :created, :telephone_service_preference => @telephone_service_preference }
          end
      end
  end

  private
  def telephone_service_preference_params
    params.require(:telephone_service_preference).permit(:service_preference_id, :domestic_call_minutes, :international_call_minutes, :domestic_call_unlimited, :international_call_unlimited)
  end
end 