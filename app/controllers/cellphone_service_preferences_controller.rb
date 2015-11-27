class CellphoneServicePreferencesController < ApplicationController
	
	def index
		@cellphone_service_preferences = CellphoneServicePreference.all
	end

  def destroy
      @cellphone_service_preference = CellphoneServicePreference.find(params[:id])
      respond_to do |format|
          if @cellphone_service_preference.destroy
            format.html { redirect_to cellphone_service_preferences_path, :notice => 'You have successfully removed a service preference' }
            format.xml  { render :xml => @cellphone_service_preference, :status => :created, :cellphone_service_preference => @cellphone_service_preference }
          end
      end
  end

  private
  def cellphone_service_preference_params
    params.require(:cellphone_service_preference).permit(:service_preference_id, :call_minutes, :text_messages, :talk_unlimited, :text_unlimited, :data_plan, :data_speed)
  end
end 