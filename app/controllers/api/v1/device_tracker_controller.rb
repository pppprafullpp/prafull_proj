class Api::V1::DeviceTrackerController < ApplicationController
  def add_devise_details
    device_id=params[:device_id]
    service_provider=params[:service_provider]
    imei=params[:imei]
    save= DeviceTracker.create!(:device_id=>device_id, :service_provider=>service_provider, :imei=>imei)
    if save
      render :json=>{
        status:"success"
      }
    end
  end
end
