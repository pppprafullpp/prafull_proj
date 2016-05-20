class Order < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal

	validates_presence_of :order_id
	validates_uniqueness_of :order_id

	# has_many :gift_orders
 	# has_many :gifts, through: :gift_orders

  	# validates_presence_of :deal_id, :app_user_id, :effective_price, :deal_price, :status

  	def order_place_time
  		self.created_at.strftime("%d/%m/%Y %I:%M %p")
  	end

  	protected
	  def before_validation_on_create
	    self.order_id = rand(36**8).to_s(36).upcase if self.new_record? and self.order_id.nil?
	  end 
  	
end
