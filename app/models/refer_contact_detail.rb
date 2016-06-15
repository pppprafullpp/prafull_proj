class ReferContactDetail < ActiveRecord::Base
  belongs_to :app_user

  def self.create_referred_users(params)
    referred_contacts = self.create(params)
    referred_contacts
  end

end
