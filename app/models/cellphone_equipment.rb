class CellphoneEquipment < ActiveRecord::Base
	belongs_to :cellphone_deal_attribute
	belongs_to :deal
	before_save :update_effective_price
	has_many :equipment_colors

	def update_effective_price
		deal_id = self.deal.present? ? self.deal.id : 0
		if deal_id > 0
			deal_attributes = CellphoneDealAttribute.where(:deal_id => self.deal.id)
			deal_attributes.each do |attribute|
				effective_price = CellphoneDealAttribute.new.cellphone_effective_price(deal,attribute)
				attribute.update_attributes(:effective_price => effective_price)
			end
		end
	end

	def available_color
		# EquipmentColor.select('color_name').where(id: eval(self.available_colors))
		EquipmentColor.where(id: eval(self.available_colors)).pluck(:color_name)
	end


end
