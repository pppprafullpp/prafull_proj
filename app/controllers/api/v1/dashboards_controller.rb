####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		###############   When User is Logged In and zip code is present   ###############	
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?											                	
			@app_user = AppUser.find_by_id(params[:app_user_id])
			@zip_code = @app_user.zip
			if @app_user.present? && @zip_code.present?
				if @app_user.user_type=="residence"
					@deal_type="residence"
				elsif @app_user.user_type=="business"
					@deal_type="business"
				end
				excluded_categories="'Gas','Electricity','Home Security'"
				@service_preferences = @app_user.service_preferences.order("created_at DESC") 
		  		@servicelist = @service_preferences.map do |sp|
		  		@app_user_current_plan = sp.price
		  		@advertisement = []
		  		@best_deal = []
		  		@trending_deal = []
		  		@t_deal = TrendingDeal.joins(:deal).where("trending_deals.category_id = ? AND deals.is_active = ? AND deals.deal_type = ?", sp.service_category_id,true,@deal_type).order("trending_deals.subscription_count DESC").first
		  		if @t_deal.present?
		  			@trending_deal = Deal.where("id=? AND is_active=? AND deal_type=?",@t_deal.deal_id,true,@deal_type).first
		  		end
		  		
		  		# For Zip code @b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, @zip_code, sp.service_category_id, Date.today).order("price ASC").first
		  		deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+@deal_type+"' AND deals.service_category_id="+sp.service_category_id.to_s+" "

		  		if sp.service_category.name == 'Internet'
		  			excluded_categories+=",'Internet'"
		  			@app_user_d_speed = sp.internet_service_preference.download_speed
		  			@equal_deals = Deal.joins(:internet_deal_attributes).where(deal_validation_conditions+" AND internet_deal_attributes.download = ?", @app_user_d_speed).order("price ASC")
					@greater_deals = Deal.joins(:internet_deal_attributes).where(deal_validation_conditions+" AND internet_deal_attributes.download > ?", @app_user_d_speed).order("price ASC").limit(2)
					
					if @equal_deals.present? && @greater_deals.present?	
						@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
					elsif @equal_deals.present? && @greater_deals.blank?
						@merged_deals = @equal_deals
					elsif @greater_deals.present? && @equal_deals.blank?	
						@merged_deals = @greater_deals
					else
						@merged_deals=Deal.joins(:internet_deal_attributes).where(deal_validation_conditions).order("price ASC")
					end
					begin
						@b_deal = @merged_deals.first
					rescue
						@b_deal = @merged_deals
					end
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			end
		  		elsif sp.service_category.name == 'Telephone'
		  			excluded_categories+=",'Telephone'"
		  			if sp.telephone_service_preference.domestic_call_unlimited == true
	  					@equal_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
						@greater_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", @app_user_current_plan).order("price ASC").limit(2)
						
						if @equal_deals.present? && @greater_deals.present?	
							@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						elsif @equal_deals.present? && @greater_deals.blank?
							@merged_deals = @equal_deals
						elsif @greater_deals.present? && @equal_deals.blank?	
							@merged_deals = @greater_deals
						else
							@merged_deals=Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions).order("price ASC")
						end
						begin
							@b_deal = @merged_deals.first
						rescue
							@b_deal = @merged_deals
						end
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end	
		  			else
		  				@app_user_c_minutes = sp.telephone_service_preference.domestic_call_minutes
		  				@equal_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes = ?", @app_user_c_minutes).order("price ASC")
						@greater_deals = Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes > ?", @app_user_c_minutes).order("price ASC").limit(2)
						if @equal_deals.present? && @greater_deals.present?	
							@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						elsif @equal_deals.present? && @greater_deals.blank?
							@merged_deals = @equal_deals
						elsif @greater_deals.present? && @equal_deals.blank?	
							@merged_deals = @greater_deals
						else
							@merged_deals=Deal.joins(:telephone_deal_attributes).where(deal_validation_conditions).order("price ASC")
						end
						begin
							@b_deal = @merged_deals.first
						rescue
							@b_deal = @merged_deals
						end
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end			
		  			end
		  		elsif sp.service_category.name == 'Cable'
		  			excluded_categories+=",'Cable'"
		  			@app_user_f_channel = sp.cable_service_preference.free_channels
		  			@equal_deals = Deal.joins(:cable_deal_attributes).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ?", @app_user_f_channel).order("price ASC")
					@greater_deals = Deal.joins(:cable_deal_attributes).where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ?", @app_user_f_channel).order("price ASC").limit(2)
					if @equal_deals.present? && @greater_deals.present?	
						@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
					elsif @equal_deals.present? && @greater_deals.blank?
						@merged_deals = @equal_deals
					elsif @greater_deals.present? && @equal_deals.blank?	
						@merged_deals = @greater_deals
					else
						@merged_deals=Deal.joins(:cable_deal_attributes).where(deal_validation_conditions).order("price ASC")
					end
					begin
						@b_deal = @merged_deals.first
					rescue
						@b_deal = @merged_deals
					end
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			end	
		  		elsif sp.service_category.name == 'Cellphone'	
		  			excluded_categories+=",'Cellphone'"
		  			if sp.cellphone_service_preference.domestic_call_unlimited == true
		  				@equal_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
		  				@greater_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price > ?", @app_user_current_plan).order("price ASC").limit(2)
		  				if @equal_deals.present? && @greater_deals.present?
		  					@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						elsif @equal_deals.present? && @greater_deals.blank?
							@merged_deals = @equal_deals
						elsif @greater_deals.present? && @equal_deals.blank?	
							@merged_deals = @greater_deals
						else
							@merged_deals=Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions).order("price ASC")
						end
						begin
							@b_deal = @merged_deals.first
						rescue
							@b_deal = @merged_deals
						end
		  				
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end	
		  			else
		  				@app_user_c_minutes = sp.cellphone_service_preference.domestic_call_minutes
		  				@equal_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes = ?", @app_user_c_minutes).order("price ASC")
		  				@greater_deals = Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes > ?", @app_user_c_minutes).order("price ASC").limit(2)
		  				if @equal_deals.present? && @greater_deals.present?	
							@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						elsif @equal_deals.present? && @greater_deals.blank?
							@merged_deals = @equal_deals
						elsif @greater_deals.present? && @equal_deals.blank?	
							@merged_deals = @greater_deals
						else
							@merged_deals=Deal.joins(:cellphone_deal_attributes).where(deal_validation_conditions).order("price ASC")
						end
						begin
							@b_deal = @merged_deals.first
						rescue
							@b_deal = @merged_deals
						end

						if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end		
		  			end
		  		elsif sp.service_category.name == 'Bundle'
		  			excluded_categories+=",'Bundle'"
		  			@app_user_bundle_combo = sp.bundle_service_preference.bundle_combo
		  			@app_user_d_speed = sp.bundle_service_preference.download_speed
		  			@equal_deals = Deal.joins(:bundle_deal_attributes).where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ?", @app_user_bundle_combo).order("price ASC")
		  			begin
						@b_deal = @equal_deals.first
					rescue
						@b_deal = @equal_deals
					end
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal
		  			end				
		  		else
		  			@b_deal = Deal.where(deal_validation_conditions).order("price ASC").first
		  			if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal
		  			end		
		  		end
		  		@adv = sp.service_category.advertisements.order("created_at DESC").first
		  		@advertisement << @adv if @adv.present?
		  		@preferred_deal = []

		  		@allowed_trending_deal=[]
		  		if @trending_deal.present?
					@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",@trending_deal.id,@zip_code)
					if not @restricted_deal.present?
						@allowed_trending_deal.push(@trending_deal)
				    end
				end

				@allowed_best_deal=[]
				@best_deal.each do |deal|
					if deal.present?
						@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],@zip_code)
						if not @restricted_deal.present?
							@allowed_best_deal.push(deal)
					    end
					end
				end

				@allowed_preferred_deal=[]
				@preferred_deal.each do |deal|
					if deal.present?
						@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],@zip_code)
						if not @restricted_deal.present?
							@allowed_preferred_deal.push(deal)
					    end
					end
				end

				{ :you_save_text => @you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :trending_deal => @allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :best_deal => @allowed_best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @allowed_preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  	end	
		  		# Show trending deals for unsubscribed services
		  		@service_categories = ServiceCategory.where("name not in ("+excluded_categories+")")
		  		@categoryList = @service_categories.map do |sc|
					@t_deal = TrendingDeal.joins(:deal).where("trending_deals.category_id = ? AND deals.is_active = ? AND deal_type = ?",sc.id,true,@deal_type).order("trending_deals.subscription_count DESC").first
			  		if @t_deal.present?
			  			@trending_deal = Deal.where("id=? AND is_active=? AND deal_type=?",@t_deal.deal_id,true,@deal_type).first
			  		end
			  		@allowed_category_trending_deals
			  		if @trending_deal.present?
						@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",@trending_deal.id,@zip_code)
						if not @restricted_deal.present?
							@allowed_category_trending_deals=@trending_deal
					    end
					end
			  		{:you_save_text => "", :contract_fee => "", :service_provider_name => @allowed_category_trending_deals.service_provider_name, :service_category_name => @allowed_category_trending_deals.service_category_name,:advertisement =>[],:trending_deal => [ @allowed_category_trending_deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])],:best_deal =>[],:preferred_deal =>[] } 
				end	

				render :json => { :dashboard_data => (@servicelist + @categoryList) }
			else
				render :json => { :success => false }
			end	
		###############   When User is not logged in and zip code is present   ###############	
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
			@service_categories = ServiceCategory.where("name in ('Internet','Telephone','Cellphone','Cable','Bundle')")
		  	@categoryList = @service_categories.map do |sc|
				@t_deal = TrendingDeal.joins(:deal).where("trending_deals.category_id = ? AND deals.is_active = ? AND deal_type = ?",sc.id,true,params[:deal_type]).order("trending_deals.subscription_count DESC").first
		  		if @t_deal.present?
		  			@trending_deal = Deal.where("id=? AND is_active=? AND deal_type=?",@t_deal.deal_id,true,params[:deal_type]).first
		  		end
		  		if @trending_deal.present?
					@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",@trending_deal.id,@zip_code)
					if not @restricted_deal.present?
						@allowed_trending_deal=@trending_deal
				    end
				end
		  		{:you_save_text => "", :contract_fee => "", :service_provider_name => @allowed_trending_deal.service_provider_name, :service_category_name => @allowed_trending_deal.service_category_name,:trending_deal => @allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
			end	
			render :json => { :dashboard_data => @categoryList }
		###############  Filtering  ###############
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].present? && params[:sorting_flag].present?
			if params[:deal_type]=="residence"
				@deal_type="residence"
			elsif params[:deal_type]=="business"
				@deal_type="business"
			end
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+@deal_type+"' AND deals.service_category_id="+params[:category]+" "

			if params[:sorting_flag] == 'download_speed' #For Internet and bundle
				if params[:category] == '1'
					@deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("internet_deal_attributes.download DESC")
				elsif params[:category] == '5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.download DESC")
				end
			elsif params[:sorting_flag] == 'price' #For all on the basis of Price
				if params[:category] == '1'
					@deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='2'
					@deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
		  		elsif params[:category]=='3'
					@deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='4'
					@deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				else
		  			@deals = Deal.where(deal_validation_conditions).order("price ASC")
		  		end
			elsif params[:sorting_flag] == 'free_channels' #For Cable
				if params[:category] == '3'
					@deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("cable_deal_attributes.free_channels DESC")
				elsif params[:category] == '5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.free_channels DESC")
				end
			elsif params[:sorting_flag] == 'call_minutes' #For CellPhone, Telephone & Bundle
				if params[:category] == '2'
					@deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("telephone_deal_attributes.domestic_call_minutes DESC")
		  		elsif params[:category] == '4'
		  			@deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("cellphone_deal_attributes.domestic_call_minutes DESC")
				elsif params[:category] == '5'
		  			@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.domestic_call_minutes DESC")
				end
		  	else
				@deals = Deal.where(deal_validation_conditions).order("price ASC")
			end
			@allowed_deals=[]
			@deals.each do |deal|
				@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],params[:zip_code])
				if not @restricted_deal.present?
					@allowed_deals.push(deal)
			    end
			end
			render :json => {:deal => @allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])}
		elsif params[:app_user_id].present? && params[:zip_code].present? && params[:category].present? && params[:sorting_flag].present?
			@app_user = AppUser.find_by_id(params[:app_user_id])
			if @app_user.user_type=="residence"
				@deal_type="residence"
			elsif @app_user.user_type=="business"
				@deal_type="business"
			end
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+@deal_type+"' AND deals.service_category_id="+params[:category]+" "

			if params[:sorting_flag] == 'download_speed' #For Internet and bundle
				if params[:category] == '1'
					@deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("internet_deal_attributes.download DESC")
				elsif params[:category] == '5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.download DESC")
				end
			elsif params[:sorting_flag] == 'price' #For all on the basis of Price
				if params[:category] == '1'
					@deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='2'
					@deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
		  		elsif params[:category]=='3'
					@deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='4'
					@deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				elsif params[:category]=='5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("deals.price ASC")
				else
		  			@deals = Deal.where(deal_validation_conditions).order("price ASC")
		  		end
			elsif params[:sorting_flag] == 'free_channels' #For Cable
				if params[:category] == '3'
					@deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions).order("cable_deal_attributes.free_channels DESC")
				elsif params[:category] == '5'
					@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.free_channels DESC")
				end
			elsif params[:sorting_flag] == 'call_minutes' #For CellPhone, Telephone & Bundle
				if params[:category] == '2'
					@deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions).order("telephone_deal_attributes.domestic_call_minutes DESC")
		  		elsif params[:category] == '4'
		  			@deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions).order("cellphone_deal_attributes.domestic_call_minutes DESC")
				elsif params[:category] == '5'
		  			@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions).order("bundle_deal_attributes.domestic_call_minutes DESC")
				end
		  	else
				@deals = Deal.where(deal_validation_conditions).order("price ASC")
			end
			@allowed_deals=[]
			@deals.each do |deal|
				@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],params[:zip_code])
				if not @restricted_deal.present?
					@allowed_deals.push(deal)
			    end
			end
			render :json => {:deal => @allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])}
		end
	end	

	def dashboard_deals
		if params[:app_user_id].present? && params[:service_category_id].present? && params[:zip_code].present?
			@app_user = AppUser.find_by_id(params[:app_user_id])
			@zip_code = @app_user.zip
			if @app_user.user_type=="residence"
				@deal_type="residence"
			elsif @app_user.user_type=="business"
				@deal_type="business"
			end
			deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+@deal_type+"' AND deals.service_category_id="+params[:service_category_id]+" "

			@user_preference = @app_user.service_preferences.where("service_category_id = ?", params[:service_category_id]).first
			@matched_deal = []
			if params[:service_category_id] == '1'
				@current_d_speed = @user_preference.internet_service_preference.download_speed 
				@equal_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download = ?", @user_preference.internet_service_preference.download_speed).order("price ASC")
				@greater_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download > ?", @user_preference.internet_service_preference.download_speed).order("price ASC")
				@smaller_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where(deal_validation_conditions+" AND internet_deal_attributes.download < ?", @user_preference.internet_service_preference.download_speed).order("price DESC")
			elsif params[:service_category_id] == '2'
				@current_plan_price = @user_preference.price
				@current_t_plan = @user_preference.telephone_service_preference.domestic_call_unlimited
				if @current_t_plan == true
					@equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", @current_plan_price).order("price ASC")
					@greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", @current_plan_price).order("price ASC")
					@smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price < ? AND telephone_deal_attributes.domestic_call_minutes='Unlimited' ", @current_plan_price).order("price DESC")
				else
					@current_c_minutes = @user_preference.telephone_service_preference.domestic_call_minutes
					@equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes = ?", @current_c_minutes).order("price ASC")
					@greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes > ?", @current_c_minutes).order("price ASC")
					@smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where(deal_validation_conditions+" AND telephone_deal_attributes.domestic_call_minutes < ?", @current_c_minutes).order("price ASC")
				end
			elsif params[:service_category_id] == '3'
				@current_plan_price = @user_preference.price
				@current_f_channels = @user_preference.cable_service_preference.free_channels
				@equal_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels = ?", @current_f_channels).order("price ASC")
				@greater_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels > ?", @current_f_channels).order("price ASC")
				@smaller_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where(deal_validation_conditions+" AND cable_deal_attributes.free_channels < ?", @current_f_channels).order("price DESC")
			elsif params[:service_category_id] == '4'
				@current_plan_price = @user_preference.price
				@current_t_plan = @user_preference.cellphone_service_preference.domestic_call_unlimited
				if @current_t_plan == true
					@equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' ").order("price ASC")
					@greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price > ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited'", @current_plan_price).order("price ASC")
					@smaller_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND deals.price < ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited'", @current_plan_price).order("price ASC")
				else
					@current_c_minutes = @user_preference.cellphone_service_preference.domestic_call_minutes
					@equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes = ?", @current_c_minutes).order("price ASC")
					@greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes > ?", @current_c_minutes).order("price ASC")
					@smaller_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes < ?", @current_c_minutes).order("price ASC")
				end	
			elsif params[:service_category_id] == '5'
				@app_user_bundle_combo = @user_preference.bundle_service_preference.bundle_combo
				@equal_deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where(deal_validation_conditions+" AND bundle_deal_attributes.bundle_combo = ?", @app_user_bundle_combo).order("price ASC").limit(5)
			end

			if @equal_deals.present? && @greater_deals.present?	
				@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
			elsif @equal_deals.present? && @greater_deals.blank?
				@merged_deals = @equal_deals
			elsif @equal_deals.blank? && @greater_deals.present?
				@merged_deals = @greater_deals
			end
					
			if @merged_deals.present?
				json_1 = @merged_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end
			if @smaller_deals.present?
				json_2 = @smaller_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end
			if json_1.present? && json_2.present?
				@matched_deal = json_1 + json_2
			elsif json_1.blank? && json_2.present?
				@matched_deal = json_2
			elsif json_1.present? && json_2.blank?
				@matched_deal = json_1		
			end
		elsif params[:app_user_id].blank? && params[:service_category_id].present? && params[:zip_code].present?
			@zip_code = params[:zip_code]
			if params[:service_category_id] == '1'
				@deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed,internet_deal_attributes.equipment,internet_deal_attributes.installation,internet_deal_attributes.activation").where("deals.is_active = ? AND deals.service_category_id = ?", true,params[:service_category_id]).order("price ASC")
			elsif params[:service_category_id] == '2'
				@deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_call_minutes,telephone_deal_attributes.countries,telephone_deal_attributes.features,telephone_deal_attributes.equipment,telephone_deal_attributes.installation,telephone_deal_attributes.activation").where("deals.is_active = ? AND deals.service_category_id = ?", true,params[:service_category_id]).order("price ASC")
			elsif params[:service_category_id] == '3'
				@deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.free_channels,cable_deal_attributes.premium_channels,cable_deal_attributes.free_channels_list,cable_deal_attributes.premium_channels_list,cable_deal_attributes.equipment,cable_deal_attributes.installation,cable_deal_attributes.activation").where("deals.is_active = ? AND deals.service_category_id = ?", true,params[:service_category_id]).order("price ASC")
			elsif params[:service_category_id] == '4'
				@deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.domestic_call_minutes,cellphone_deal_attributes.international_call_minutes,cellphone_deal_attributes.domestic_text,cellphone_deal_attributes.international_text,cellphone_deal_attributes.data_plan,cellphone_deal_attributes.data_speed,cellphone_deal_attributes.equipment,cellphone_deal_attributes.installation,cellphone_deal_attributes.activation").where("deals.is_active = ? AND deals.service_category_id = ?", true, params[:service_category_id]).order("price ASC")
			elsif params[:service_category_id] == '5'
				@deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.free_channels,bundle_deal_attributes.premium_channels,bundle_deal_attributes.free_channels_list,bundle_deal_attributes.premium_channels_list,bundle_deal_attributes.domestic_call_minutes,bundle_deal_attributes.international_call_minutes,bundle_deal_attributes.download as download_speed,bundle_deal_attributes.upload as upload_speed,bundle_deal_attributes.equipment,bundle_deal_attributes.installation,bundle_deal_attributes.activation").where("deals.is_active = ? AND deals.service_category_id = ?", true,params[:service_category_id]).order("price ASC")
			end

			if @deals.present?
				json = @deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price_value])
			end

			if json.present?
				@matched_deal = json
			end

		end	

		@allowed_deals=[]
		@matched_deal.each do |deal|
			@restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",deal['id'],@zip_code)
			if not @restricted_deal.present?
				@allowed_deals.push(deal)
		    end
		end
		render :json => {:deal => @allowed_deals }
	end

end	
		