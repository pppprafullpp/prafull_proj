class Business < ActiveRecord::Base
  has_many :business_addresses
  has_many :business_app_users
  validates :business_name,:uniqueness => true
  before_save { self.business_name = business_name.squish if business_name.present?}
  ## business type
  SOLE_PROPRIETOR = 0
  REGISTERED = 1

  BUSINESS_TYPES = {'Sole Proprietor' => SOLE_PROPRIETOR, 'Registered' => REGISTERED}

  ## business status
  NEW = 'New'
  EXISTING = 'Existing'
  RECONTRACTED = 'Recontracted'
  RENEWAL = 'Renewal'
  UPGRADE = 'Upgrade'

  def self.create_business(params)
    if params[:business].present?
      business_type = params[:business][:business_type].present? ? params[:business][:business_type].to_i : nil
      if business_type.present?
        if business_type == SOLE_PROPRIETOR
          business = self.where(:ssn => params[:business][:ssn]).first
        elsif business_type == REGISTERED
          business = self.where(:federal_number => params[:business][:federal_number]).first
        end
        unless business.present?
          business = self.new
        else
          business = business
        end
        params[:business].each do |key,value|
          business[key] = value
        end
        if business.save!
          business
        else
          business
        end
      end
    else
      nil
    end
  end

end