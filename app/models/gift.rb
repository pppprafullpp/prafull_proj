class Gift < ActiveRecord::Base
	has_many :gift_orders
  has_many :orders, through: :gift_orders

  validates_presence_of :name, :description, :amount, :is_active, :activation_count_condition
end
