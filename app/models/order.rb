class Order < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal

	validates_uniqueness_of :order_id
	
	has_many :user_gifts,:dependent => :destroy
 	has_many :gifts, through: :user_gifts

  	# validates_presence_of :deal_id, :app_user_id, :effective_price, :deal_price, :status

  	def order_place_time
  		self.created_at.strftime("%d/%m/%Y %I:%M %p")
  	end

end
