class BusinessAddress < ActiveRecord::Base
  belongs_to :business

  ## address type constants
  BRANCH_ADDRESS = 0
  SHIPPING_ADDRESS = 1
  BILLING_ADDRESS = 2
  BUSINESS_ADDRESS = 3
  HOME_ADDRESS = 4

  def self.create_business_addresses(params,business_id)
    business_addresses = []
    params[:business_addresses].each do |address|
      business_address = self.where(:address_name => address[:address_name],:business_id => business_id).first
      unless business_address.present?
        business_address = self.new
        business_address.business_id = business_id
        address.each do |key,value|
          business_address[key] = value
        end
        if business_address.save!
          business_addresses << business_address
        end
      else
        business_addresses << business_address
      end
    end
    business_addresses
  end

end