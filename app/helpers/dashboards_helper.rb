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

			  		allowed_order_deal=category_order_deal(app_user_id,sp.service_category_id,false)
			  		
			  		allowed_best_deal=category_best_deal(deal_type,sp,zip_code,1,false)
		  			
		  			if allowed_best_deal.present?
		  				if allowed_best_deal.effective_price.to_f>0
		  					you_save = '%.2f' % (app_user_current_plan - allowed_best_deal.effective_price.to_f)	
		  			    else
		  			    	you_save = '%.2f' % (app_user_current_plan - allowed_best_deal.price)
		  			    end
		  			else
		  				you_save = ""
		  			end
		  				
		  			if allowed_best_deal.present? && allowed_order_deal.present? && allowed_best_deal.id==allowed_order_deal.id
		  				allowed_order_deal=allowed_order_deal
		  			end	

		  			if allowed_trending_deal.present? && allowed_order_deal.present? && allowed_trending_deal.id==allowed_order_deal.id
		  				allowed_order_deal=allowed_order_deal
		  			end	

			  		{:you_save_text => you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_id => sp.service_category.id, :service_category_name => sp.service_category.name, :advertisement => advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price]), :best_deal => allowed_best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price]),:order_deal => allowed_order_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price])} 
			  	end	
		  		# Show trending deals for unsubscribed services
		  		service_categories = ServiceCategory.where("name not in ("+excluded_categories+")")
		  		categoryList = service_categories.map do |sc|
					allowed_trending_deal = category_trending_deal(deal_type,sc.id,zip_code)
			  		
			  		if allowed_trending_deal.present?
			  			service_provider_name=allowed_trending_deal.service_provider_name
			  		else
						service_provider_name=""
					end

					{:you_save_text => "", :contract_fee => "", :service_provider_name => service_provider_name, :service_category_id => sc.id, :service_category_name => sc.name,:advertisement =>nil,:trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price]),:best_deal =>nil} 
				end	

				render :json => { :dashboard_data => (servicelist + categoryList) }
			else
				render :json => { :success => false }
			end
		else
			service_categories = ServiceCategory.where("name in ('Internet','Telephone','Cellphone','Cable','Bundle')")
		  	categoryList = service_categories.map do |sc|
				
				allowed_trending_deal = category_trending_deal(deal_type,sc.id,zip_code)

				if allowed_trending_deal.present?
					service_provider_name=allowed_trending_deal.service_provider_name
				else
					service_provider_name=""
				end
		  		
		  		{:you_save_text => "", :contract_fee => "", :service_provider_name => service_provider_name, :service_category_id => sc.id, :service_category_name => sc.name,:trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price]) } 
			end	
			render :json => { :dashboard_data => categoryList }
		end
	end

	def category_order_deal(app_user_id,category_id,return_attributes)
		
		order_deals=Deal.joins(:orders).select("deals.id").where("deals.service_category_id = ? AND orders.app_user_id = ?",category_id,app_user_id)

		if return_attributes==true
			select_fields_internet="deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed"
			select_fields_telephone="deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features"
			select_fields_cable="deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list"
			select_fields_cellphone="deals.*,cellphone_deal_attributes.no_of_lines,cellphone_deal_attributes.price_per_line,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.additional_data,cellphone_deal_attributes.rollover_data"
			select_fields_bundle="deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed"
		else
			select_fields_internet="deals.*"
			select_fields_telephone="deals.*"
			select_fields_cable="deals.*"
			select_fields_cellphone="deals.*"
			select_fields_bundle="deals.*"
		end
		# app_user = AppUser.find(app_user_id)
		# app_user.service_preferences
		# last_order_deal_id = app_user.orders.last.deal_id rescue nil
		# .order("deals.price ASC").where(id: last_order_deal_id).first
		
		if category_id == 1
			order_deal = Deal.joins(:internet_deal_attributes).joins(:orders).select(select_fields_internet).where("deals.id in (?)",order_deals).to_a.last
		elsif category_id == 2
			order_deal = Deal.joins(:telephone_deal_attributes).joins(:orders).select(select_fields_telephone).where("deals.id in (?)",order_deals).to_a.last
			# where(id: last_order_deal_id).first
		elsif category_id == 3
			order_deal = Deal.joins(:cable_deal_attributes).joins(:orders).select(select_fields_cable).where("deals.id in (?)",order_deals).to_a.last
		elsif category_id == 4
			order_deal = Deal.joins(:cellphone_deal_attributes).joins(:orders).select(select_fields_cellphone).where("deals.id in (?)",order_deals).to_a.last
		elsif category_id == 5
			order_deal = Deal.joins(:bundle_deal_attributes).joins(:orders).select(select_fields_bundle).where("deals.id in (?)",order_deals).to_a.last
		end

  		if order_deal.present?
  			return order_deal
  		else
  			return nil
  		end
  	end

	def filtered_deals(app_user_id,category_id,zip_code,deal_type,sorting_key)
		if app_user_id.present?
			app_user = AppUser.find_by_id(app_user_id)
			zip_code = app_user.zip
			deal_type=app_user.user_type
		end

		restricted_deals=Deal.joins(:deals_zipcodes).joins(:zipcodes).select("deals.id").where("zipcodes.code= ? ",zip_code)
		deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

		select_fields_internet="deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed"
		select_fields_telephone="deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features"
		select_fields_cable="deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list"
		select_fields_cellphone="deals.*,cellphone_deal_attributes.no_of_lines,cellphone_deal_attributes.price_per_line,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.additional_data,cellphone_deal_attributes.rollover_data"
		select_fields_bundle="deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed"
												
		if sorting_key == 'download_speed' #For Internet and bundle
			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("internet_deal_attributes.download DESC,deals.price ASC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("bundle_deal_attributes.download DESC,deals.price ASC")
			end
		elsif sorting_key == 'price' #For all on the basis of Price
			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("deals.price ASC")
			elsif category_id=='2'
				deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("deals.price ASC")
	  		elsif category_id=='3'
				deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("deals.price ASC")
			elsif category_id=='4'
				deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("deals.price ASC")
			elsif category_id=='5'
				deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("deals.price ASC")
			else
	  			deals = Deal.where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
	  		end
		elsif sorting_key == 'free_channels' #For Cable
			if category_id == '3'
				deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("cable_deal_attributes.free_channels DESC,deals.price ASC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("bundle_deal_attributes.free_channels DESC,deals.price ASC")
			end
		elsif sorting_key == 'call_minutes' #For CellPhone, Telephone & Bundle
			if category_id == '2'
				deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("telephone_deal_attributes.domestic_call_minutes DESC,deals.price ASC")
	  		elsif category_id == '4'
	  			deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("cellphone_deal_attributes.domestic_call_minutes DESC,deals.price ASC")
			elsif category_id == '5'
	  			deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("bundle_deal_attributes.domestic_call_minutes DESC,deals.price ASC")
			end
	  	else
			deals = Deal.where(deal_validation_conditions).order("price ASC")
		end

		return deals
	end

	def category_trending_deal(deal_type,category_id,zip_code)
		restricted_deals=Deal.joins(:deals_zipcodes).joins(:zipcodes).select("deals.id").where("zipcodes.code= ? ",zip_code)

		allowed_trending_deal=Deal.joins(:trending_deals).where("deals.id not in (?) AND deals.is_active = ? AND deals.deal_type = ? AND deals.service_category_id = ?",restricted_deals,true,deal_type,category_id).order("trending_deals.subscription_count DESC").first

  		if not allowed_trending_deal.present?
  			allowed_trending_deal=Deal.where("deals.id not in (?) AND deals.is_active = ? AND deals.deal_type = ? AND deals.service_category_id = ?",restricted_deals,true,deal_type,category_id).order("price ASC").first
  		end

  		return allowed_trending_deal
  	end
  	
  	def category_best_deal(deal_type,sp,zip_code,return_count,return_attributes)
  		restricted_deals=Deal.joins(:deals_zipcodes).joins(:zipcodes).select("deals.id").where("zipcodes.code= ? ",zip_code)
  		deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+sp.service_category_id.to_s+" "
		
		if return_attributes==true
			select_fields_internet="deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed"
			select_fields_telephone="deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features"
			select_fields_cable="deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list"
			select_fields_cellphone="deals.*,cellphone_deal_attributes.no_of_lines,cellphone_deal_attributes.price_per_line,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.additional_data,cellphone_deal_attributes.rollover_data"
			select_fields_bundle="deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed"
		else
			select_fields_internet="deals.*"
			select_fields_telephone="deals.*"
			select_fields_cable="deals.*"
			select_fields_cellphone="deals.*"
			select_fields_bundle="deals.*"
		end
		
		if sp.service_category.name == 'Internet'
  			app_user_download_speed = sp.internet_service_preference.download_speed
  			best_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download > ? AND price < ? AND deals.id not in (?)", app_user_download_speed,sp.price,restricted_deals).order("price ASC")
			if best_deals.blank?
				best_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download = ? AND price < ? AND deals.id not in (?)", app_user_download_speed,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download > ? AND price = ? AND deals.id not in (?)", app_user_download_speed,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download = ? AND price <= ? AND deals.id not in (?)", app_user_download_speed,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download < ? AND price <= ? AND deals.id not in (?)", app_user_download_speed,sp.price,restricted_deals).order("download DESC").order("price ASC")
			end
			if best_deals.blank?
				best_deals=Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
			end
		elsif sp.service_category.name == 'Telephone'
  			if sp.telephone_service_preference.domestic_call_unlimited == true
				best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes='Unlimited' AND price < ? AND deals.id not in (?)", sp.price, restricted_deals).order("price ASC")
				if best_deals.blank?
					best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes='Unlimited' AND price = ? AND deals.id not in (?)", sp.price, restricted_deals).order("price ASC")
				end
				if best_deals.blank?
					best_deals=Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + " AND telephone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?)",restricted_deals).order("price ASC")
				end
  			else
  				app_user_call_minutes = sp.telephone_service_preference.domestic_call_minutes
  				best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND telephone_deal_attributes.domestic_call_minutes > ? AND price < ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
				if best_deals.blank?
					best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND telephone_deal_attributes.domestic_call_minutes = ? AND price < ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
				end
				if best_deals.blank?
					best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND telephone_deal_attributes.domestic_call_minutes > ? AND price = ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
				end
				if best_deals.blank?
					best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND telephone_deal_attributes.domestic_call_minutes = ? AND price <= ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
				end
				if best_deals.blank?
					best_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND telephone_deal_attributes.domestic_call_minutes < ? AND price <= ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("domestic_call_minutes DESC").order("price ASC")
				end
				if best_deals.blank?
					best_deals=Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + " AND telephone_deal_attributes.domestic_call_minutes!='Unlimited' AND deals.id not in (?)",restricted_deals).order("price ASC")
				end
			end
  		elsif sp.service_category.name == 'Cable'
  			app_user_free_channels = sp.cable_service_preference.free_channels
  			best_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ? AND price < ? AND deals.id not in (?)", app_user_free_channels,sp.price,restricted_deals).order("price ASC")
			if best_deals.blank?
				best_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ? AND price < ? AND deals.id not in (?)", app_user_free_channels,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ? AND price = ? AND deals.id not in (?)", app_user_free_channels,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ? AND price <= ? AND deals.id not in (?)", app_user_free_channels,sp.price,restricted_deals).order("price ASC")
			end
			if best_deals.blank?
				best_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels < ? AND price <= ? AND deals.id not in (?)", app_user_free_channels,sp.price,restricted_deals).order("free_channels DESC").order("price ASC")
			end
			if best_deals.blank?
				best_deals=Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
			end
  		elsif sp.service_category.name == 'Cellphone'	
  			if sp.cellphone_service_preference.domestic_call_unlimited == true
  				best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price < ? AND deals.id not in (?)", sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
					best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price = ? AND deals.id not in (?)", sp.price,restricted_deals).order("price ASC")
  				end
				if best_deals.blank?
					best_deals=Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + " AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?)",restricted_deals).order("price ASC")
				end
  			else
  				app_user_call_minutes = sp.cellphone_service_preference.domestic_call_minutes
  				best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes > ? AND price < ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
  					best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes = ? AND price < ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes > ? AND price = ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes = ? AND price <= ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes < ? AND price <= ? AND deals.id not in (?)", app_user_call_minutes,sp.price,restricted_deals).order("domestic_call_minutes DESC").order("price ASC")
  				end
				if best_deals.blank?
					best_deals=Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + " AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND deals.id not in (?)",restricted_deals).order("price ASC")
				end
			end
  		elsif sp.service_category.name == 'Bundle'
  			app_user_bundle_combo = sp.bundle_service_preference.bundle_combo
  			if app_user_bundle_combo=="Internet,Telephone and Cable"
  				app_user_download_speed = sp.bundle_service_preference.download_speed
  				app_user_call_minutes = sp.bundle_service_preference.domestic_call_minutes
  				app_user_free_channels = sp.bundle_service_preference.free_channels
  				best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND bundle_deal_attributes.free_channels = ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND bundle_deal_attributes.free_channels = ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price <= ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,sp.price+10,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND deals.id not in (?)", app_user_bundle_combo,restricted_deals).order("price ASC")
  				end
  			elsif app_user_bundle_combo=="Internet and Telephone"
  				app_user_download_speed = sp.bundle_service_preference.download_speed
  				app_user_call_minutes = sp.bundle_service_preference.domestic_call_minutes
  				best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND price <= ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,sp.price+10,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND deals.id not in (?)", app_user_bundle_combo,restricted_deals).order("price ASC")
  				end
  			elsif app_user_bundle_combo=="Internet and Cable"
  				app_user_download_speed = sp.bundle_service_preference.download_speed
  				app_user_free_channels = sp.bundle_service_preference.free_channels
  				best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.free_channels > ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.free_channels = ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.free_channels > ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download = ? AND bundle_deal_attributes.free_channels = ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.free_channels > ? AND price <= ? AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,sp.price+10,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND deals.id not in (?)", app_user_bundle_combo,restricted_deals).order("price ASC")
  				end
  			elsif app_user_bundle_combo=="Telephone and Cable"
  				app_user_call_minutes = sp.bundle_service_preference.domestic_call_minutes
  				app_user_free_channels = sp.bundle_service_preference.free_channels
  				best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND bundle_deal_attributes.free_channels = ? AND price < ? AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes = ? AND bundle_deal_attributes.free_channels = ? AND price = ? AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,sp.price,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND price <= ? AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,sp.price+10,restricted_deals).order("price ASC")
  				end
  				if best_deals.blank?
  					best_deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND deals.id not in (?)", app_user_bundle_combo,restricted_deals).order("price ASC")
  				end
  			end
  		else
  			best_deals = Deal.where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
  		end

  		if best_deals.present?
  			if return_count==1
  				return best_deals.first
  			else
				return best_deals
			end
		else
			best_deals = nil
		end
		
  	end

  	def get_category_deals(app_user_id,category_id,zip_code,deal_type)
  		
  		select_fields_internet="deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed"
		select_fields_telephone="deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features"
		select_fields_cable="deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list"
		select_fields_cellphone="deals.*,cellphone_deal_attributes.no_of_lines,cellphone_deal_attributes.price_per_line,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.additional_data,cellphone_deal_attributes.rollover_data"
		select_fields_bundle="deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed"
		
  		if app_user_id.present?
  			app_user = AppUser.find_by_id(app_user_id)
			zip_code = app_user.zip
			deal_type=app_user.user_type
		
			restricted_deals=Deal.joins(:deals_zipcodes).joins(:zipcodes).select("deals.id").where("zipcodes.code= ? ",zip_code)
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

			user_preference = app_user.service_preferences.where("service_category_id = ?",category_id).first
			matched_deal = []
			if category_id == '1'
				if user_preference.present?
					current_download_speed = user_preference.internet_service_preference.download_speed
					best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
					greater_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download > ? AND deals.id not in (?) AND deals.id not in (?)", current_download_speed,restricted_deals,best_deals.ids).order("price ASC")
					smaller_deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+" AND internet_deal_attributes.download < ? AND deals.id not in (?) AND deals.id not in (?)", current_download_speed,restricted_deals,best_deals.ids).order("price DESC")
				else
					deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions+ " AND deals.id not in (?)",restricted_deals).order("price ASC")
					
					if deals.present?
						json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
					end

					if json.present?
						matched_deal = json
					end
				end
			elsif category_id == '2'
				if user_preference.present?
					current_plan_price = user_preference.price
					current_t_plan = user_preference.telephone_service_preference.domestic_call_unlimited
					if current_t_plan == true
						best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
						greater_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND deals.price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?) AND deals.id not in (?)",current_plan_price,restricted_deals,best_deals.ids).order("price ASC")
						smaller_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND deals.price < ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?) AND deals.id not in (?)",current_plan_price,restricted_deals,best_deals.ids).order("price DESC")
					else
						current_call_minutes = user_preference.telephone_service_preference.domestic_call_minutes
						best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
						greater_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes > ? AND deals.id not in (?) AND deals.id not in (?)", current_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
						smaller_deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes < ? AND deals.id not in (?) AND deals.id not in (?)", current_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
					end
				else
					deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + " AND deals.id not in (?)", restricted_deals).order("price ASC")
					
					if deals.present?
						json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
					end

					if json.present?
						matched_deal = json
					end
				end
			elsif category_id == '3'
				if user_preference.present?
					current_plan_price = user_preference.price
					current_free_channels = user_preference.cable_service_preference.free_channels
					best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
					greater_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ? AND deals.id not in (?) AND deals.id not in (?)", current_free_channels,restricted_deals,best_deals.ids).order("price ASC")
					smaller_deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels < ? AND deals.id not in (?) AND deals.id not in (?)", current_free_channels,restricted_deals,best_deals.ids).order("price DESC")
				else
					deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
					
					if deals.present?
						json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
					end

					if json.present?
						matched_deal = json
					end
				end
			elsif category_id == '4'
				if user_preference.present?
					current_plan_price = user_preference.price
					current_t_plan = user_preference.cellphone_service_preference.domestic_call_unlimited
					if current_t_plan == true
						best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
						greater_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND deals.price > ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?) AND deals.id not in (?)", current_plan_price,restricted_deals,best_deals.ids).order("price ASC")
						smaller_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND deals.price < ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.id not in (?) AND deals.id not in (?)", current_plan_price,restricted_deals,best_deals.ids).order("price ASC")
					else
						current_call_minutes = user_preference.cellphone_service_preference.domestic_call_minutes
						best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
						greater_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes > ? AND deals.id not in (?) AND deals.id not in (?)", current_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
						smaller_deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes < ? AND deals.id not in (?) AND deals.id not in (?)", current_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
					end
				else
					deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + " AND deals.id not in (?)", restricted_deals).order("price ASC")
					
					if deals.present?
						json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
					end

					if json.present?
						matched_deal = json
					end
				end
			elsif category_id == '5'
				if user_preference.present?
					app_user_bundle_combo = user_preference.bundle_service_preference.bundle_combo
					best_deals = category_best_deal(deal_type,user_preference,zip_code,nil,true)
					if app_user_bundle_combo=="Internet,Telephone and Cable"
		  				app_user_download_speed = user_preference.bundle_service_preference.download_speed
		  				app_user_call_minutes = user_preference.bundle_service_preference.domestic_call_minutes
		  				app_user_free_channels = user_preference.bundle_service_preference.free_channels
		  				greater_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  				smaller_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download < ? AND bundle_deal_attributes.domestic_call_minutes < ? AND bundle_deal_attributes.free_channels < ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  			elsif app_user_bundle_combo=="Internet and Telephone"
		  				app_user_download_speed = user_preference.bundle_service_preference.download_speed
		  				app_user_call_minutes = user_preference.bundle_service_preference.domestic_call_minutes
		  				greater_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.domestic_call_minutes > ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
		  				smaller_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download < ? AND bundle_deal_attributes.domestic_call_minutes < ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_call_minutes,restricted_deals,best_deals.ids).order("price ASC")
		  			elsif app_user_bundle_combo=="Internet and Cable"
		  				app_user_download_speed = user_preference.bundle_service_preference.download_speed
		  				app_user_free_channels = user_preference.bundle_service_preference.free_channels
		  				greater_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download > ? AND bundle_deal_attributes.free_channels > ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  				smaller_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.download < ? AND bundle_deal_attributes.free_channels < ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_download_speed,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  			elsif app_user_bundle_combo=="Telephone and Cable"
		  				app_user_call_minutes = user_preference.bundle_service_preference.domestic_call_minutes
		  				app_user_free_channels = user_preference.bundle_service_preference.free_channels
		  				greater_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes > ? AND bundle_deal_attributes.free_channels > ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  				greater_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ? AND bundle_deal_attributes.domestic_call_minutes < ? AND bundle_deal_attributes.free_channels < ? AND deals.id not in (?) AND deals.id not in (?)", app_user_bundle_combo,app_user_call_minutes,app_user_free_channels,restricted_deals,best_deals.ids).order("price ASC")
		  			end
				else
					deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + " AND deals.id not in (?)",restricted_deals).order("price ASC")
					
					if deals.present?
						json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
					end

					if json.present?
						matched_deal = json
					end
				end
			end

			if best_deals.present? && greater_deals.present?	
				merged_deals = best_deals + greater_deals
			elsif best_deals.present? && greater_deals.blank?
				merged_deals = best_deals
			elsif best_deals.blank? && greater_deals.present?
				merged_deals = greater_deals
			end
					
			if merged_deals.present?
				json_1 = merged_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
			end
			if smaller_deals.present?
				json_2 = smaller_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
			end
			if json_1.present? && json_2.present?
				matched_deal = json_1 + json_2
			elsif json_1.blank? && json_2.present?
				matched_deal = json_2
			elsif json_1.present? && json_2.blank?
				matched_deal = json_1		
			end
		else
			restricted_deals=Deal.joins(:deals_zipcodes).joins(:zipcodes).select("deals.id").where("zipcodes.code= ? ",zip_code)
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+deal_type+"' AND deals.service_category_id="+category_id+" "

			if category_id == '1'
				deals = Deal.joins(:internet_deal_attributes).select(select_fields_internet).where(deal_validation_conditions + "AND deals.id not in (?)", restricted_deals).order("price ASC")
			elsif category_id == '2'
				deals = Deal.joins(:telephone_deal_attributes).select(select_fields_telephone).where(deal_validation_conditions + "AND deals.id not in (?)", restricted_deals).order("price ASC")
			elsif category_id == '3'
				deals = Deal.joins(:cable_deal_attributes).select(select_fields_cable).where(deal_validation_conditions + "AND deals.id not in (?)", restricted_deals).order("price ASC")
			elsif category_id == '4'
				deals = Deal.joins(:cellphone_deal_attributes).select(select_fields_cellphone).where(deal_validation_conditions + "AND deals.id not in (?)", restricted_deals).order("price ASC")
			elsif category_id == '5'
				deals = Deal.joins(:bundle_deal_attributes).select(select_fields_bundle).where(deal_validation_conditions + "AND deals.id not in (?)", restricted_deals).order("price ASC")
			end

			if deals.present?
				json = deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :effective_price, :service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])
			end

			if json.present?
				matched_deal = json
			end
		end	

		return matched_deal
  	end
end