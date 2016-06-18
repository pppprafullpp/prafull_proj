class AppUserAddress < ActiveRecord::Base
  belongs_to :app_user

  def self.create_app_user_addresses(params,app_user_id)
    app_user_addresses = []
    params[:app_user_addresses].each do |address|
      app_user_address = self.where(:address_name => address[:address_name],:app_user_id => app_user_id).first
      unless app_user_address.present?
        app_user_address = self.new
        app_user_address.app_user_id = app_user_id
        address.each do |key,value|
          app_user_address[key] = value
        end
        if app_user_address.save!
          app_user_addresses << app_user_address
        end
      else
        app_user_addresses << app_user_address
      end
    end
    app_user_addresses
  end

end