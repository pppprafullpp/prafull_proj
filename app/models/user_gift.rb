class UserGift < ActiveRecord::Base
	belongs_to :app_user 
	belongs_to :order
	belongs_to :gift
end
