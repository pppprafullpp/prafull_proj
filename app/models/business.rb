class Business < ActiveRecord::Base
  has_many :business_addresses
  has_many :business_app_users
  validates :business_name,:uniqueness => true

  ## business type
  SOLE_PROPRIETOR = 0
  REGISTERED = 1

  ## business status
  NEW = 'New'
  EXISTING = 'Existing'
  RECONTRACTED = 'Recontracted'
  RENEWAL = 'Renewal'
  UPGRADE = 'Upgrade'

  def self.create_business(params)
    business = self.new
    params[:business].each do |key,value|
      business[key] = value
    end
    if business.save!
      business
    else
      business
    end
  end


end