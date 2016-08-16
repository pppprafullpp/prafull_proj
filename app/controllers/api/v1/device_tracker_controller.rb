class Api::V1::DeviceTrackerController < ApplicationController
  def add_devise_details
    session_token=SecureRandom.hex(5)
    if !DeviceRegister.find_by_device_id(params[:device_id])
      # Device not yet registered
      save=DeviceRegister.create!(:device_id=>params[:device_id],:imei=>params[:imei], :token=>session_token)
      register_or_update(params,1,save.id)
    else
      #Device already registered ,so just updating token and registering information
      device=DeviceRegister.find_by_device_id(params[:device_id])
      device.update_attributes(:token=> session_token)
      register_or_update(params,2,device.id)
    end
    render :json=>{
      session_token: session_token
    }
  end

  def register_or_update(params,type,id)
    params[:device_register_id]=id
    DeviceTracker.create!(
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
    :roaming=>params[:roaming],
    :device_register_id=>id)
  end

  def destroy_session
    DeviceRegister.find_by_device_id(params[:device_id]).update_attributes(:token=>"")
    render :json=>{
      status: "Session Destroyed"
    }
  end
end
