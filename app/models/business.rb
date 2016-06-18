class Business < ActiveRecord::Base
  has_many :business_addresses
  has_many :business_app_users
  validates :business_name,:federal_number,:uniqueness => true
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
    business_type = params[:business][:business_type].present? ? params[:business][:business_type].to_i : SOLE_PROPRIETOR
    if business_type == SOLE_PROPRIETOR
      business = self.where(:ssn => params[:business][:ssn]).first
    elsif business_type == REGISTERED
      business = self.where(:federal_number => params[:business][:federal_number]).first
    end
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