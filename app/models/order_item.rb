class OrderItem < ActiveRecord::Base
  belongs_to :order
  before_create :add_default_details

  def self.create_order_items(params,order_id)
    order_items = []
    params[:order_items].each do |item|
      order_item = self.new
      order_item.order_id = order_id
      item.each do |key,value|
        order_item[key] = value
      end
      if order_item.save!
        order_items << order_item
      end
    end
    order_items
  end

  private
  def add_default_details
    self.activation_date = Time.now
    self.status = Order::NEW_ORDER
  end

end