class Order < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal
	has_many :gift_orders
  	has_many :gifts, through: :gift_orders

  	validates_presence_of :deal_id, :app_user_id, :effective_price, :deal_price, :status, :activation_date
end
