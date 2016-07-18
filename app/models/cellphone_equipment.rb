class CellphoneEquipment < ActiveRecord::Base
	belongs_to :cellphone_deal_attribute
	belongs_to :deal
end
