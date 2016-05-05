class CellphoneDealAttribute < ActiveRecord::Base
	has_many :cellphone_equipments, dependent: :destroy
    accepts_nested_attributes_for :cellphone_equipments,:reject_if => :reject_equipment, allow_destroy: true
  
  	def reject_equipment(attributes)
	    if attributes[:model].blank?
	      if attributes[:id].present?
	        attributes.merge!({:_destroy => 1}) && false
	      else
	        true
	      end
	    end
	end
end
