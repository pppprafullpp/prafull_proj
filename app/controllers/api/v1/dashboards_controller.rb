####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index

		###############   When User is Logged In and zip code is present   ###############	
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank? && params[:state].blank?											                	
			@app_user = AppUser.find_by_id(params[:app_user_id])
			#@zip_code = @app_user.zip
			@state = @app_user.state
			if @app_user.present? && @state.present? #@zip_code.present?
				@service_preferences = @app_user.service_preferences.order("created_at DESC") 
		  	@servicelist = @service_preferences.map do |sp|
		  		@app_user_current_plan = sp.price
		  		@advertisement = []
		  		@best_deal = []
		  		@trending_deal = []
		  		@t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
		  		if @t_deal.present?
		  			@trending = Deal.find_by_id(@t_deal.deal_id)
		  			@trending_deal << @trending
		  		end
		  		# For Zip code @b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, @zip_code, sp.service_category_id, Date.today).order("price ASC").first
		  		if sp.service_category_id == 1
		  			@app_user_d_speed = sp.internet_service_preference.download_speed
		  			@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, sp.service_category_id).order("price ASC")
						@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, sp.service_category_id).order("price ASC").limit(2)
						#@smaller_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND download_speed < ?", true, @state, sp.service_category_id, @app_user_d_speed).order("price DESC").limit(2)
						@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						@b_deal = @merged_deals.first
		  			#@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND download_speed = ? AND price <= ?", true, @state, sp.service_category_id, Date.today, @app_user_d_speed, @app_user_current_plan).order("price ASC").first
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			end
		  		elsif sp.service_category_id == 2
		  			if sp.telephone_service_preference.domestic_call_unlimited == true
		  				@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, sp.service_category_id).order("price ASC")
							#@smaller_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND price < ?", true, @state, params[:service_category_id], false, @current_plan_price).order("price DESC").limit(2)
							@greater_deals = Deal.where("is_active = ? AND service_category_id = ? AND price > ?", true, sp.service_category_id, @app_user_current_plan).order("price ASC").limit(2)
							@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
							@b_deal = @merged_deals.first
		  				#@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND domestic_call_unlimited = ?", true, @state, sp.service_category_id, Date.today, true).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end	
		  			else
		  				@app_user_c_minutes = sp.telephone_service_preference.domestic_call_minutes
		  				@equal_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND domestic_call_minutes = ? AND price = ?", true, @state, sp.service_category_id, false, @app_user_c_minutes, @app_user_current_plan).order("price ASC")
							#@smaller_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND domestic_call_minutes < ?", true, @state, params[:service_category_id], false, @current_c_minutes).order("price ASC").limit(2)
							@greater_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND domestic_call_unlimited = ? AND domestic_call_minutes > ?", true, @state, sp.service_category_id, false, @app_user_c_minutes).order("price ASC").limit(2)
							
							@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
							@b_deal = @merged_deals.first
		  				#@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND domestic_call_minutes = ?", true, @state, sp.service_category_id, Date.today, @app_user_c_minutes).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end			
		  			end
		  		elsif sp.service_category_id == 3
		  			@app_user_f_channel = sp.cable_service_preference.free_channels
		  			@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, sp.service_category_id).order("price ASC")
						#@smaller_deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND free_channels < ?", true, @state, params[:service_category_id], @current_f_channels).order("price DESC")
						@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, sp.service_category_id).order("price ASC").limit(2)
						@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
						@b_deal = @merged_deals.first
		  			#@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND free_channels = ?", true, @state, sp.service_category_id, Date.today, @app_user_f_channel).order("price ASC").first
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			end	
		  		elsif sp.service_category_id == 4	
		  			if sp.cellphone_service_preference.domestic_call_unlimited == true
		  				@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					end
		  				end	
		  			else
		  				@app_user_c_minutes = sp.cellphone_service_preference.domestic_call_minutes
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND domestic_call_minutes = ?", true, @state, sp.service_category_id, Date.today, @app_user_c_minutes).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					else
		  						@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price DESC").first
		  						if @b_deal.present?
		  							@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  							@best_deal << @b_deal
		  						else
		  							@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  							if @b_deal.present?
		  								@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  								@best_deal << @b_deal
		  							end
		  						end	
		  					end
		  				end		
		  			end
		  		elsif sp.service_category_id == 5
		  			@app_user_bundle_combo = sp.bundle_service_preference.bundle_combo
		  			@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal
		  			end				
		  		else
		  			@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  			if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal
		  			end		
		  		end
		  		@adv = sp.service_category.advertisements.order("created_at DESC").first
		  		@advertisement << @adv if @adv.present?
		  		@preferred_deal = []
					{ :you_save_text => @you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :trending_deal => @trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  	end	
				render :json => { :dashboard_data => @servicelist }
			else
				render :json => { :success => false }
			end	

			###############   When User is Logged In and ServiceCategory and ZipCode both are present   ###############
		
		elsif params[:zip_code].present? && params[:category].present? && params[:app_user_id].present? && params[:sorting_flag].present? && params[:state].blank?
			@app_user = AppUser.find_by_id(params[:app_user_id])
			@state = @app_user.state
			if params[ :sorting_flag] == 'download_speed' #For Internet
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("download_speed DESC")
			elsif params[ :sorting_flag] == 'price' #For all on the basis of Price
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("price ASC")
			elsif params[ :sorting_flag] == 'free_channels' #For Cable
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("free_channels DESC")
			elsif params[ :sorting_flag] == 'domestic_call_minutes' #For CellPhone & Telephone
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("domestic_call_minutes DESC")
		  else
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("price ASC")
			end
			render :json => {:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])}
		end
	end	

	def dashboard_deals
		@app_user = AppUser.find_by_id(params[:app_user_id])
		@state = @app_user.state
		if @app_user.present? && @state.present? #@zip_code.present?
			@user_preference = @app_user.service_preferences.where("service_category_id = ?", params[:service_category_id]).first
			@matched_deal = []
			if params[:service_category_id] == '1'
				@current_d_speed = @user_preference.internet_service_preference.download_speed 
				@equal_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed").where("deals.is_active = ? AND deals.service_category_id = ? AND internet_deal_attributes.download = ?", true, params[:service_category_id],@user_preference.internet_service_preference.download_speed).order("price ASC")
				@greater_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed").where("deals.is_active = ? AND deals.service_category_id = ? AND internet_deal_attributes.download > ?", true, params[:service_category_id],@user_preference.internet_service_preference.download_speed).order("price ASC").limit(2)
				@smaller_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.download as download_speed,internet_deal_attributes.upload as upload_speed").where("deals.is_active = ? AND deals.service_category_id = ? AND internet_deal_attributes.download < ?", true, params[:service_category_id],@user_preference.internet_service_preference.download_speed).order("price DESC").limit(2)
			elsif params[:service_category_id] == '2'
				@current_plan_price = @user_preference.price
				@current_t_plan = @user_preference.telephone_service_preference.domestic_call_unlimited
				if @current_t_plan == true
					@equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ?", true, params[:service_category_id]).order("price ASC")
					@smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ? AND deals.price < ?", true, params[:service_category_id], @current_plan_price).order("price DESC").limit(2)
					@greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ? AND deals.price > ?", true, params[:service_category_id], @current_plan_price).order("price ASC").limit(2)
				else
					@current_c_minutes = @user_preference.telephone_service_preference.domestic_call_minutes
					@equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ? AND deals.price <= ? AND telephone_deal_attributes.domestic_call_minutes = ?", true, params[:service_category_id], @current_plan_price,@user_preference.telephone_service_preference.domestic_call_minutes).order("price ASC")
					@smaller_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes = ?", true, params[:service_category_id],@user_preference.telephone_service_preference.domestic_call_minutes).order("price ASC").limit(2)
					@greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.domestic_call_minutes,telephone_deal_attributes.international_landline_minutes as international_call_minutes").where("deals.is_active = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes = ?", true, params[:service_category_id],@user_preference.telephone_service_preference.domestic_call_minutes).order("price ASC").limit(2)
				end
			elsif params[:service_category_id] == '3'
				@current_plan_price = @user_preference.price
				@current_f_channels = @user_preference.cable_service_preference.free_channels
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
				@smaller_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price DESC").limit(2)
				@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
			elsif params[:service_category_id] == '4'
				@current_plan_price = @user_preference.price
				@current_t_plan = @user_preference.cellphone_service_preference.domestic_call_unlimited
				if @current_t_plan == true
					@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC")
					@smaller_deals = Deal.where("is_active = ? AND service_category_id = ? AND price < ?", true, params[:service_category_id], @current_plan_price).order("price DESC").limit(2)
					@greater_deals = Deal.where("is_active = ? AND service_category_id = ? AND price > ?", true, params[:service_category_id], @current_plan_price).order("price ASC").limit(2)
				else
					@current_c_minutes = @user_preference.cellphone_service_preference.domestic_call_minutes
					@equal_deals = Deal.where("is_active = ? AND service_category_id = ? AND price <= ?", true, params[:service_category_id], @current_plan_price).order("price ASC")
					@smaller_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price DESC").limit(2)
					@greater_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(2)
				end	
			elsif params[:service_category_id] == '5'
				@app_user_bundle_combo = @user_preference.bundle_service_preference.bundle_combo
				@equal_deals = Deal.where("is_active = ? AND service_category_id = ?", true, params[:service_category_id]).order("price ASC").limit(5)
			end
			if @equal_deals.present? && @greater_deals.present?	
				@merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
			elsif @equal_deals.present? && @greater_deals.blank?
				@merged_deals = (@equal_deals).sort_by(&:price)
			elsif @equal_deals.blank? && @greater_deals.present?	
				@merged_deals = (@greater_deals).sort_by(&:price)
			end
			if @merged_deals.present?
				json_1 = @merged_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name])
			end
			#if @greater_deals.present?
			#	json_2 = @greater_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
			#end
			if @smaller_deals.present?
				json_2 = @smaller_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price, :service_category_name, :service_provider_name])
			end
			if json_1.present? && json_2.present?
				@matched_deal = json_1 + json_2
			elsif json_1.blank? && json_2.present?
				@matched_deal = json_2
			elsif json_1.present? && json_2.blank?
				@matched_deal = json_1		
			end
		end	
		render :json => {:deal => @matched_deal }
	end

end	
		