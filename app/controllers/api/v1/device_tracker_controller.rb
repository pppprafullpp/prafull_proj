class Api::V1::DeviceTrackerController < ApplicationController
  def add_devise_details
    save= DeviceTracker.create!(
    :device_id=>params[:device_id],
    :service_provider=>params[:service_provider],
    :imei=>params[:imei],
    :dual_sim=>params[:dual_sim],
    :country=>params[:country],
    :sim_operator=>params[:sim_operator],
    :sim_serial_number=>params[:sim_serial_number],
    :voice_mail_number=>params[:voice_mail_number],
    :location=>params[:location],
    :device_type=>params[:device_type],
    :provider_type=>params[:provider_type],
    :roaming=>params[:roaming])
    if save
      render :json=>{
        status:"success"
      }
    end
  end
end
