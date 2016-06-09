class Business < ActiveRecord::Base
  has_many :business_addresses
  has_many :business_app_users
  validates :business_name,:uniqueness => true
  before_save { self.business_name = business_name.squish }
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
    business = self.where(:business_name => params[:business][:business_name]).first
    unless business.present?
      business = self.new
      params[:business].each do |key,value|
        business[key] = value
      end
      if business.save!
        business
      else
        business
      end
    else
      business
    end
  end


end