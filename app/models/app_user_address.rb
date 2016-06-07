class AppUserAddress < ActiveRecord::Base
  belongs_to :app_user

  def self.create_app_user_addresses(params)
    app_user_address = self.new
    params[:app_user_address].each do |key,value|
      app_user_address[key] = value
    end
    if app_user_address.save!
      app_user_address
    else
      app_user_address
    end
  end

end