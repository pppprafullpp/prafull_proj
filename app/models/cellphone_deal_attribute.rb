class CellphoneDealAttribute < ActiveRecord::Base
	validates :data_plan_price,:additional_data_price,:no_of_lines,:price_per_line, :presence => true
	has_many :cellphone_equipments, dependent: :destroy
	accepts_nested_attributes_for :cellphone_equipments,:reject_if => :reject_equipment, allow_destroy: true

	belongs_to :deal

	before_save :update_effective_price

	def reject_equipment(attributes)
		if attributes[:model].blank?
			if attributes[:id].present?
				attributes.merge!({:_destroy => 1}) && false
			else
				true
			end
		end
	end

	def update_effective_price
		deal = self.deal
		if deal.present?
			equipment=deal.cellphone_equipments.first
			effective_price=(self.no_of_lines*self.price_per_line)+self.data_plan_price+self.additional_data_price
			if equipment.present?
				effective_price+=(self.no_of_lines*equipment.price)
			end
			if deal.additional_offers.present?
				deal.additional_offers.each do |additional_offer|
					effective_price-=additional_offer.price
				end
			end
			self.effective_price = effective_price
		end
	end

end
