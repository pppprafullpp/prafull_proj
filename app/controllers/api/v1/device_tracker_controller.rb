class Api::V1::DeviceTrackerController < ApplicationController
  def add_devise_details
    device_id=params[:device_id]
    service_provider=params[:service_provider]
    save= DeviceTracker.create!(:device_id=>device_id, :service_provider=>service_provider)
    if save
      render :json=>{
        status:"success"
      }
    end
  end
end
