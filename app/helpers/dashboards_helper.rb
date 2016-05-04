module DashboardsHelper
	def user_dashboard_deals(app_user_id)
		app_user = AppUser.find_by_id(app_user_id)
		zip_code = app_user.zip
		if app_user.present? && zip_code.present?
			if app_user.user_type=="residence"
				deal_type="residence"
			elsif app_user.user_type=="business"
				deal_type="business"
			end
			excluded_categories="'Gas','Electricity','Home Security'"
			service_preferences = app_user.service_preferences.order("created_at DESC") 
	  		@servicelist = service_preferences.map do |sp|
	  			
	  			app_user_current_plan = sp.price
		  		
		  		trending_deal = category_trending_deal(deal_type,sp.service_category_id)
		  		
		  		if sp.service_category.name == 'Internet'
		  			excluded_categories+=",'Internet'"
		  		elsif sp.service_category.name == 'Telephone'
		  			excluded_categories+=",'Telephone'"
		  		elsif sp.service_category.name == 'Cable'
		  			excluded_categories+=",'Cable'"
		  		elsif sp.service_category.name == 'Cellphone'	
		  			excluded_categories+=",'Cellphone'"
		  		elsif sp.service_category.name == 'Bundle'
		  			excluded_categories+=",'Bundle'"
		  		end
		  		
		  		best_deal=category_best_deal(deal_type,sp)
	  			if best_deal.present?
	  				you_save = '%.2f' % (app_user_current_plan - best_deal.price)
	  			else
	  				you_save = ""
	  			end
		  		
		  		advertisement = sp.service_category.advertisements.order("created_at DESC").first
		  		if advertisement.blank?
		  			advertisement=nil
		  		end
		  		
		  		if trending_deal.present?
					restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",trending_deal.id,zip_code)
					if not restricted_deal.present?
						allowed_trending_deal=trending_deal
					else
						allowed_trending_deal=nil
				    end
				end

				if best_deal.present?
					restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",best_deal.id,zip_code)
					if not restricted_deal.present?
						allowed_best_deal=best_deal
					else
						allowed_best_deal=nil
				    end
				end
				
				{ :you_save_text => you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_id => sp.service_category.id, :service_category_name => sp.service_category.name, :advertisement => advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :best_deal => allowed_best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])} 
		  	end	
	  		# Show trending deals for unsubscribed services
	  		@service_categories = ServiceCategory.where("name not in ("+excluded_categories+")")
	  		@categoryList = @service_categories.map do |sc|

				trending_deal = category_trending_deal(deal_type,sc.id)

		  		if trending_deal.present?
					restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",trending_deal.id,zip_code)
					if not restricted_deal.present?
						allowed_category_trending_deal=trending_deal
					else
						allowed_category_trending_deal=""
				    end
				end
		  		{:you_save_text => "", :contract_fee => "", :service_provider_name => allowed_category_trending_deal.service_provider_name, :service_category_id => allowed_category_trending_deal.service_category_id, :service_category_name => allowed_category_trending_deal.service_category_name,:advertisement =>nil,:trending_deal => allowed_category_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]),:best_deal =>nil} 
			end	

			render :json => { :dashboard_data => (@servicelist + @categoryList) }
		else
			render :json => { :success => false }
		end
	end

	def category_trending_deal(deal_type,category_id)
		Deal.joins(:trending_deals).where("deals.is_active = ? AND deals.deal_type = ? AND deals.service_category_id = ?",true,deal_type,category_id).order("trending_deals.subscription_count DESC").first
  	end
  	def category_best_deal(deal_type,sp)
  		deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+sp.service_category_id.to_s+" "
		if sp.service_category.name == 'Internet'
  			app_user_d_speed = sp.internet_service_preference.download_speed
  			equal_deals = Deal.joins(:internet_deal_attributes).where(deal_validation_conditions+" AND internet_deal_attributes.download = ?", app_user_d_speed).order("price ASC")
			greater_deals = Deal.joins(:internet_deal_attributes).where(deal_validation_conditions+" AND internet_deal_attributes.download > ?", app_user_d_speed).order("price ASC").limit(2)
			
			if equal_deals.present? && greater_deals.present?	
				merged_deals = (equal_deals + greater_deals).sort_by(&:price)
			elsif equal_deals.present? && greater_deals.blank?
				merged_deals = equal_deals
			elsif greater_deals.present? && equal_deals.blank?	
				merged_deals = greater_deals
			else
				merged_deals=Deal.joins(:internet_deal_attributes).where(deal_validation_conditions).order("price ASC")
			end
			if merged_deals.present?
				best_deal = merged_deals.first
			else
				best_deal = ""
			end

  		elsif sp.service_category.name == 'Telephone'
  			if sp.telephone_service_preference.domestic_call_unlimited == true
				equal_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
				greater_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", sp.price).order("price ASC").limit(2)
				
				if equal_deals.present? && greater_deals.present?	
					merged_deals = (equal_deals + greater_deals).sort_by(&:price)
				elsif equal_deals.present? && greater_deals.blank?
					merged_deals = equal_deals
				elsif greater_deals.present? && equal_deals.blank?	
					merged_deals = greater_deals
				else
					merged_deals=Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions).order("price ASC")
				end
				if merged_deals.present?
					best_deal = merged_deals.first
				else
					best_deal = ""
				end
  			else
  				app_user_c_minutes = sp.telephone_service_preference.domestic_call_minutes
  				equal_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes = ?", app_user_c_minutes).order("price ASC")
				greater_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes > ?", app_user_c_minutes).order("price ASC").limit(2)
				if equal_deals.present? && greater_deals.present?	
					merged_deals = (equal_deals + greater_deals).sort_by(&:price)
				elsif equal_deals.present? && greater_deals.blank?
					merged_deals = equal_deals
				elsif greater_deals.present? && equal_deals.blank?	
					merged_deals = greater_deals
				else
					merged_deals=Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions).order("price ASC")
				end
				if merged_deals.present?
					best_deal = merged_deals.first
				else
					best_deal = ""
				end
  			end
  		elsif sp.service_category.name == 'Cable'
  			app_user_f_channel = sp.cable_service_preference.free_channels
  			equal_deals = Deal.joins(:cable_deal_attributes).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ?", app_user_f_channel).order("price ASC")
			greater_deals = Deal.joins(:cable_deal_attributes).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ?", app_user_f_channel).order("price ASC").limit(2)
			if equal_deals.present? && greater_deals.present?	
				merged_deals = (equal_deals + greater_deals).sort_by(&:price)
			elsif equal_deals.present? && greater_deals.blank?
				merged_deals = equal_deals
			elsif greater_deals.present? && equal_deals.blank?	
				merged_deals = greater_deals
			else
				merged_deals=Deal.joins(:cable_deal_attributes).where(deal_validation_conditions).order("price ASC")
			end
			if merged_deals.present?
				best_deal = merged_deals.first
			else
				best_deal = ""
			end
  		elsif sp.service_category.name == 'Cellphone'	
  			if sp.cellphone_service_preference.domestic_call_unlimited == true
  				equal_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
  				greater_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price > ?", sp.price).order("price ASC").limit(2)
  				if equal_deals.present? && greater_deals.present?
  					merged_deals = (equal_deals + greater_deals).sort_by(&:price)
				elsif equal_deals.present? && greater_deals.blank?
					merged_deals = equal_deals
				elsif greater_deals.present? && equal_deals.blank?	
					merged_deals = greater_deals
				else
					merged_deals=Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions).order("price ASC")
				end
				if merged_deals.present?
					best_deal = merged_deals.first
				else
					best_deal = ""
				end
  			else
  				app_user_c_minutes = sp.cellphone_service_preference.domestic_call_minutes
  				equal_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes = ?", app_user_c_minutes).order("price ASC")
  				greater_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes > ?", app_user_c_minutes).order("price ASC").limit(2)
  				if equal_deals.present? && greater_deals.present?
  					merged_deals = (equal_deals + greater_deals).sort_by(&:price)
				elsif equal_deals.present? && greater_deals.blank?
					merged_deals = equal_deals
				elsif greater_deals.present? && equal_deals.blank?	
					merged_deals = greater_deals
				else
					merged_deals=Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions).order("price ASC")
				end
				if merged_deals.present?
					best_deal = merged_deals.first
				else
					best_deal = ""
				end
			end
  		elsif sp.service_category.name == 'Bundle'
  			app_user_bundle_combo = sp.bundle_service_preference.bundle_combo
  			app_user_d_speed = sp.bundle_service_preference.download_speed
  			equal_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ?", app_user_bundle_combo).order("price ASC")
  			
  			if equal_deals.present?
				best_deal = equal_deals.first
			else
				best_deal = ""
			end
  		else
  			best_deal = Deal.where(deal_validation_conditions).order("price ASC").first
  		end
  	end
end