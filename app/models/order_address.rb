class OrderAddress < ActiveRecord::Base
  belongs_to :order

  def self.create_order_addresses(params,order_id)
    order_addresses = []
    order_addresses_param = params[:business_addresses].present? ? params[:business_addresses] : params[:app_user_addresses].present? ? params[:app_user_addresses] : []
    order_addresses_param.each do |address|
      order_address = self.new
      order_address.order_id = order_id
      address.each do |key,value|
        order_address[key] = value
      end
      if order_address.save!
        order_addresses << order_address
      end
    end
    order_addresses
  end

end