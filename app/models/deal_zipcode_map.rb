class DealZipcodeMap < ActiveRecord::Base
	belongs_to :deal
	belongs_to :zipcode
end
