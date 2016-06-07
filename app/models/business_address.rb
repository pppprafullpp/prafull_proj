class BusinessAddress < ActiveRecord::Base
  belongs_to :business

  ## address type constants
  BRANCH_ADDRESS = 0
  SHIPPING_ADDRESS = 1
  BILLING_ADDRESS = 2
  BUSINESS_ADDRESS = 3
  HOME_ADDRESS = 4

  def self.create_business_address(params,business_id)
    business_address = self.new
    business_address.business_id = business_id
    params[:business_address].each do |key,value|
      business_address[key] = value
    end
    if business_address.save!
      business_address
    else
      business_address
    end
  end

end