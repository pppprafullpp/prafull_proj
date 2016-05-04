class CellphoneDealAttribute < ActiveRecord::Base
	has_many :cellphone_equipments
  accepts_nested_attributes_for :cellphone_equipments
end
