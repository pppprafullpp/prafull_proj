module DashboardsHelper
	def get_dashboard_deals(app_user_id,zip_code,deal_type)
		if app_user_id.present?
			app_user = AppUser.find_by_id(app_user_id)
			zip_code = app_user.zip
			if app_user.present? && zip_code.present?
				deal_type=app_user.user_type
				
				excluded_categories="'Gas','Electricity','Home Security'"

				service_preferences = app_user.service_preferences.order("created_at DESC") 
		  		servicelist = service_preferences.map do |sp|
		  			
		  			app_user_current_plan = sp.price
			  		
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
			  		
			  		advertisement = sp.service_category.advertisements.order("created_at DESC").first
			  		if advertisement.blank?
			  			advertisement=nil
			  		end

			  		allowed_trending_deal = category_trending_deal(deal_type,sp.service_category_id,zip_code)
			  		
			  		allowed_best_deal=category_best_deal(deal_type,sp,zip_code)
		  			if allowed_best_deal.present?
		  				you_save = '%.2f' % (app_user_current_plan - allowed_best_deal.price)
		  			else
		  				you_save = ""
		  			end
			  		
					{ :you_save_text => you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_id => sp.service_category.id, :service_category_name => sp.service_category.name, :advertisement => advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :best_deal => allowed_best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])} 
			  	end	
		  		# Show trending deals for unsubscribed services
		  		service_categories = ServiceCategory.where("name not in ("+excluded_categories+")")
		  		categoryList = service_categories.map do |sc|
					allowed_trending_deal = category_trending_deal(deal_type,sc.id,zip_code)
			  		{:you_save_text => "", :contract_fee => "", :service_provider_name => allowed_trending_deal.service_provider_name, :service_category_id => allowed_trending_deal.service_category_id, :service_category_name => allowed_trending_deal.service_category_name,:advertisement =>nil,:trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]),:best_deal =>nil} 
				end	

				render :json => { :dashboard_data => (servicelist + categoryList) }
			else
				render :json => { :success => false }
			end
		else
			service_categories = ServiceCategory.where("name in ('Internet','Telephone','Cellphone','Cable','Bundle')")
		  	categoryList = service_categories.map do |sc|
				
				allowed_trending_deal = category_trending_deal(deal_type,sc.id,zip_code)
		  		
		  		{:you_save_text => "", :contract_fee => "", :service_provider_name => allowed_trending_deal.service_provider_name, :service_category_id => allowed_trending_deal.service_category_id, :service_category_name => allowed_trending_deal.service_category_name,:trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
			end	
			render :json => { :dashboard_data => categoryList }
		end
	end

	def filtered_deals(app_user_id,category_id,zip_code,deal_type,sorting_key)
		if app_user_id.present?
			app_user = AppUser.find_by_id(app_user_id)
			zip_code = app_user.zip
			deal_type=app_user.user_type
		end

		deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

		if sorting_key == 'download_speed' #For Internet and bundle
			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("internet_deal_attributes.download DESC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.download DESC")
			end
		elsif sorting_key == 'price' #For all on the basis of Price
			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
			elsif category_id=='2'
				deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
	  		elsif category_id=='3'
				deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
			elsif category_id=='4'
				deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
			elsif category_id=='5'
				deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
			else
	  			deals = Deal.where(deal_validation_conditions).order("price ASC")
	  		end
		elsif sorting_key == 'free_channels' #For Cable
			if category_id == '3'
				deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("cable_deal_attributes.free_channels DESC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.free_channels DESC")
			end
		elsif sorting_key == 'call_minutes' #For CellPhone, Telephone & Bundle
			if category_id == '2'
				deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("telephone_deal_attributes.domestic_call_minutes DESC")
	  		elsif category_id == '4'
	  			deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("cellphone_deal_attributes.domestic_call_minutes DESC")
			elsif category_id == '5'
	  			deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.domestic_call_minutes DESC")
			end
	  	else
			deals = Deal.where(deal_validation_conditions).order("price ASC")
		end

		allowed_deals=[]
		deals.each do |deal|
			restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal.id,zip_code)
			if not restricted_deal.present?
				allowed_deals.push(deal)
		    end
		end
	end

	def category_trending_deal(deal_type,category_id,zip_code)
		trending_deal=Deal.joins(:trending_deals).where("deals.is_active = ? AND deals.deal_type = ? AND deals.service_category_id = ?",true,deal_type,category_id).order("trending_deals.subscription_count DESC").first
  		if trending_deal.present?
			restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",trending_deal.id,zip_code)
			if not restricted_deal.present?
				allowed_trending_deal=trending_deal
			else
				allowed_trending_deal=nil
		    end
		else
			allowed_trending_deal=nil
		end
  	end
  	
  	def category_best_deal(deal_type,sp,zip_code)
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
				
			end
  		elsif sp.service_category.name == 'Bundle'
  			app_user_bundle_combo = sp.bundle_service_preference.bundle_combo
  			app_user_d_speed = sp.bundle_service_preference.download_speed
  			merged_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ?", app_user_bundle_combo).order("price ASC")
  			
  		else
  			merged_deals = Deal.where(deal_validation_conditions).order("price ASC")
  		end

  		if merged_deals.present?
			best_deal = merged_deals.first
		else
			best_deal = nil
		end

		if best_deal.present?
			restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",best_deal.id,zip_code)
			if not restricted_deal.present?
				allowed_best_deal=best_deal
			else
				allowed_best_deal=nil
		    end
		else
			allowed_best_deal=nil
		end
  	end

  	def get_category_deals(app_user_id,category_id,zip_code,deal_type)
  		if app_user_id.present?
  			app_user = AppUser.find_by_id(app_user_id)
			zip_code = app_user.zip
			deal_type=app_user.user_type
		
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

			user_preference = app_user.service_preferences.where("service_category_id = ?",category_id).first
			matched_deal = []
			if category_id == '1'
				current_d_speed = user_preference.internet_service_preference.download_speed 
				equal_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download = ?", user_preference.internet_service_preference.download_speed).order("price ASC")
				greater_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download > ?", user_preference.internet_service_preference.download_speed).order("price ASC")
				smaller_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download < ?", user_preference.internet_service_preference.download_speed).order("price DESC")
			elsif category_id == '2'
				current_plan_price = user_preference.price
				current_t_plan = user_preference.telephone_service_preference.domestic_call_unlimited
				if current_t_plan == true
					equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", current_plan_price).order("price ASC")
					greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", current_plan_price).order("price ASC")
					smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price < ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", current_plan_price).order("price DESC")
				else
					current_c_minutes = user_preference.telephone_service_preference.domestic_call_minutes
					equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes = ?", current_c_minutes).order("price ASC")
					greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes > ?", current_c_minutes).order("price ASC")
					smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes < ?", current_c_minutes).order("price ASC")
				end
			elsif category_id == '3'
				current_plan_price = user_preference.price
				current_f_channels = user_preference.cable_service_preference.free_channels
				equal_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ?", current_f_channels).order("price ASC")
				greater_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ?", current_f_channels).order("price ASC")
				smaller_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels < ?", current_f_channels).order("price DESC")
			elsif category_id == '4'
				current_plan_price = user_preference.price
				current_t_plan = user_preference.cellphone_service_preference.domestic_call_unlimited
				if @current_t_plan == true
					equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
					greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited'", current_plan_price).order("price ASC")
					smaller_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price < ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited'", current_plan_price).order("price ASC")
				else
					current_c_minutes = user_preference.cellphone_service_preference.domestic_call_minutes
					equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes = ?", current_c_minutes).order("price ASC")
					greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes > ?", current_c_minutes).order("price ASC")
					smaller_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes < ?", current_c_minutes).order("price ASC")
				end	
			elsif category_id == '5'
				app_user_bundle_combo = user_preference.bundle_service_preference.bundle_combo
				equal_deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ?", app_user_bundle_combo).order("price ASC").limit(5)
			end

			if equal_deals.present? && greater_deals.present?	
				merged_deals = (equal_deals + greater_deals).sort_by(&:price)
			elsif equal_deals.present? && greater_deals.blank?
				merged_deals = equal_deals
			elsif equal_deals.blank? && greater_deals.present?
				merged_deals = greater_deals
			end
					
			if merged_deals.present?
				json_1 = merged_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end
			if smaller_deals.present?
				json_2 = smaller_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end
			if json_1.present? && json_2.present?
				matched_deal = json_1 + json_2
			elsif json_1.blank? && json_2.present?
				matched_deal = json_2
			elsif json_1.present? && json_2.blank?
				matched_deal = json_1		
			end
		else
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("price ASC")
			elsif category_id == '2'
				deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("price ASC")
			elsif category_id == '3'
				deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("price ASC")
			elsif category_id == '4'
				deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("price ASC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("price ASC")
			end

			if deals.present?
				json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end

			if json.present?
				matched_deal = json
			end
		end	

		allowed_deals=[]
		matched_deal.each do |deal|
			restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],zip_code)
			if not restricted_deal.present?
				allowed_deals.push(deal)
		    end
		end
  	end
end