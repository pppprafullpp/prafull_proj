class BundleDealAttribute < ActiveRecord::Base
	belongs_to :deal
	has_many :bundle_equipments, dependent: :destroy
	accepts_nested_attributes_for :bundle_equipments,:reject_if => :reject_equipment, allow_destroy: true

	def reject_equipment(attributes)
		if attributes[:name].blank?
			if attributes[:id].present?
				attributes.merge!({:_destroy => 1}) && false
			else
				true
			end
		end
	end

	def self.get_linked_bundle_deal(category_id,deal_type,app_user_id = nil)
		#bundle_category_id = ServiceCategory.get_id_by_name(ServiceCategory::BUNDLE_CATEGORY)
		category_name = ServiceCategory.get_category_name_by_id(category_id)
		# bundle_deals = Deal.find_by_sql("select deals.* from deals
		# 													inner join bundle_deal_attributes bda on bda.deal_id = deals.id
		# 													where bundle_combo like '%#{category_name}%'  AND deals.deal_type = deal_type
		# 													order by effective_price asc limit 5")
		if app_user_id == nil
			bundle_deals = Deal.find_by_sql("select deals.* from deals inner join bundle_deal_attributes bda on bda.deal_id = deals.id where deals.deal_type='#{deal_type}' AND bundle_combo like '%#{category_name}%'  order by effective_price asc limit 5")
		else
			current_service = ServicePreference.find_by_sql("select #{category_name}.* from servicedeals.service_preferences sp
																											inner join servicedeals.#{category_name}_service_preferences csp on csp.service_preference_id = sp.id
																											where app_user_id = ?",app_user_id)
			current_service = current_service.present? ? current_service.first : nil
			## TODO add logic to match the bundle deals on the current service criteria
			## like for cellphone check data plan/no of minutes etc in bundle and offer that bundle only.
			if category_id.to_i == Deal::CELLPHONE_CATEGORY
				## LOGIC HERE
			elsif category_id.to_i == Deal::INTERNET_CATEGORY
				## LOGIC HERE
			end
		end

		bundle_deals
	end

end
