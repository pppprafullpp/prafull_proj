####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index

		###############   When User is Logged In and zip code is present   ###############	
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[ :sort_by_d_speed].blank? && params[:state].blank?											                	
			@app_user = AppUser.find_by_id(params[:app_user_id])
			#@zip_code = @app_user.zip
			@state = @app_user.state
			if @app_user.present? && @state.present? #@zip_code.present?
				@service_preferences = @app_user.service_preferences.order("created_at DESC") 
		  	@servicelist = @service_preferences.map do |sp|
		  		@app_user_current_plan = sp.price
		  		@advertisement = []
		  		@best_deal = []
		  		# For Zip code @b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, @zip_code, sp.service_category_id, Date.today).order("price ASC").first
		  		if sp.service_category_id == 1
		  			@app_user_d_speed = sp.internet_service_preference.download_speed
		  			@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND download_speed >= ? AND price <= ?", true, @state, sp.service_category_id, Date.today, @app_user_d_speed, @app_user_current_plan).order("price ASC").first
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			else
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('price - download_speed ASC').first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end
		  			end	
		  		elsif sp.service_category_id == 2
		  			if sp.telephone_service_preference.talk_unlimited == false
		  				@app_user_c_minutes = sp.telephone_service_preference.call_minutes
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND call_minutes >= ? AND price <= ?", true, @state, sp.service_category_id, Date.today, @app_user_c_minutes, @app_user_current_plan).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('call_minutes / price DESC').first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					end
		  				end		
		  			else
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND talk_unlimited = ? AND price <= ?", true, @state, sp.service_category_id, Date.today, true, @app_user_current_plan).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND talk_unlimited = ?", true, @state, sp.service_category_id, Date.today, true).order("price ASC").first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					else
		  						@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('call_minutes / price DESC').first	
		  						if @b_deal.present?
		  							@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  							@best_deal << @b_deal
		  						end
		  					end
		  				end	
		  			end
		  		elsif sp.service_category_id == 3
		  			@app_user_f_channel = sp.cable_service_preference.free_channels
		  			@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND free_channels >= ? AND price <= ?", true, @state, sp.service_category_id, Date.today, @app_user_f_channel, @app_user_current_plan).order("price ASC").first
		  			if @b_deal.present?
		  				@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  				@best_deal << @b_deal 
		  			else
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('free_channels - price DESC').first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				end
		  			end	
		  		elsif sp.service_category_id == 4	
		  			if sp.cellphone_service_preference.talk_unlimited == false
		  				@app_user_c_minutes = sp.cellphone_service_preference.call_minutes
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND call_minutes >= ? AND price <= ?", true, @state, sp.service_category_id, Date.today, @app_user_c_minutes, @app_user_current_plan).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('call_minutes / price DESC').first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					end
		  				end		
		  			else
		  				@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND talk_unlimited = ? AND price <= ?", true, @state, sp.service_category_id, Date.today, true, @app_user_current_plan).order("price ASC").first
		  				if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal 
		  				else
		  					@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ? AND talk_unlimited = ?", true, @state, sp.service_category_id, Date.today, true).order("price ASC").first
		  					if @b_deal.present?
		  						@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  						@best_deal << @b_deal
		  					else
		  						@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order('call_minutes / price DESC').first	
		  						if @b_deal.present?
		  							@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  							@best_deal << @b_deal
		  						end
		  					end
		  				end	
		  			end
		  		else
		  			@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, sp.service_category_id, Date.today).order("price ASC").first
		  			if @b_deal.present?
		  					@you_save = '%.2f' % (@app_user_current_plan - @b_deal.price)
		  					@best_deal << @b_deal
		  			end		
		  		end
		  		@adv = sp.service_category.advertisements.order("created_at DESC").first
		  		@advertisement << @adv if @adv.present?
		  		@preferred_deal = []
					{ :you_save_text => @you_save, :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  		
		  		#sp.service_category.service_providers.map do |pp|
		  		#	if pp.is_preferred == true
		  		#		@preferred_deal = []
		  		#		@p_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND service_provider_id = ? AND end_date > ?", true, @zip_code, pp.service_category_id, pp.id, Date.today).order("price ASC").first
					#		@preferred_deal << @p_deal
					#	else
					#		@preferred_deal = []
		  		#	end
		  		#end	
		  		#if sp.service_category_id == 1
		  		#	{ :you_save_text => @you_save, :contract_fee => sp.price, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  		#else	
		  		#end
		  	end	
				render :json => { :dashboard_data => @servicelist }
			else
				render :json => { :success => false }
			end	

			###############   When User is Logged In and ServiceCategory and ZipCode both are present   ###############
		
		elsif params[:zip_code].present? && params[:category].present? && params[:app_user_id].present? && params[:sorting_flag].present? && params[:state].blank?
			@app_user = AppUser.find_by_id(params[:app_user_id])
			@state = @app_user.state
			#@service_preference = ServicePreference.joins(:app_user).where("app_user_id = ? AND service_category_id = ?", params[:app_user_id], params[:category]).take
			#@app_user_current_plan = @service_preference.price
			#if params[:category] == '1'
		  #	@app_user_current_plan = @service_preference.price
		  #else
		  #	@app_user_current_plan = @service_preference.contract_fee
		  #end	
			#@deals = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, params[:zip_code], params[:category], Date.today).order("price ASC")
			if params[ :sorting_flag] == 'download_speed' #For Internet
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("download_speed DESC")
			elsif params[ :sorting_flag] == 'price' #For all on the basis of Price
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("price ASC")
			elsif params[ :sorting_flag] == 'free_channels' #For Cable
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("free_channels DESC")
			elsif params[ :sorting_flag] == 'call_minutes' #For CellPhone & Telephone
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("call_minutes DESC")
			#elsif params[ :sorting_flag] == 'price'
			#	@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("free_channels DESC")
			#elsif params[ :sorting_flag] == 'price'
			#	@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("free_channels DESC")
			#elsif params[ :sorting_flag] == 'price'	
			#	@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("free_channels DESC")
			else
				@deals = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, @state, params[:category], Date.today).order("price ASC")
			end
			#byebug
			#@you_save = @b_deal.price - @app_user_current_plan
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}
		end
	end	
end
		###############   WHen State is present   ###############
		#elsif params[:state].present? && params[:category].blank? && params[:app_user_id].blank? && params[:zip_code].blank?
		#	@service_categories = ServiceCategory.all
		#	@servicelist = @service_categories.map do |sc|
		#		@sc_id = sc.id
		#		@advertisement = []
		#		@adv = sc.advertisements.order("created_at DESC").first
		#		@advertisement << @adv if @adv.present?
    #    	@best_deal = []
    #    	@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, params[:state], @sc_id, Date.today).order("price ASC").first
    #   		if @b_deal.present?
    #   			@best_deal << @b_deal
    #   		else
    #   			@best_deal = []
    #   		end		
    #    @preferred_deal = []
		#		{ :service_category_name => sc.name, :contract_fee => '0', :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 	
		#	end	
		#	render :json => { :dashboard_data => @servicelist	}
		#end                

				###############   When only Zip Code is present   ###############
		#elsif params[:zip_code].present? && params[:category].blank? && params[:app_user_id].blank? && params[:state].blank?
		#	@service_categories = ServiceCategory.all
		#	@servicelist = @service_categories.map do |sc|
		#		@sc_id = sc.id
		#		@advertisement = []
		#		@adv = sc.advertisements.order("created_at DESC").first
		#		@advertisement << @adv if @adv.present?
    #   	@best_deal = []
    #  	@b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, params[:zip_code], @sc_id, Date.today).order("price ASC").first
    #   		if @b_deal.present?
    #   			@best_deal << @b_deal
    #   		else
    #   			@best_deal = []
    #   		end		
    #    @preferred_deal = []
		#		{ :service_category_name => sc.name, :contract_fee => '0', :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 	
		#	end	
		#	render :json => { :dashboard_data => @servicelist	}

		###############   When only Service Category is present   ###############
		#elsif params[:category].present? && params[:app_user_id].blank? && params[:zip_code].blank? && params[:state].blank?
		#	@deals = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, params[:category], Date.today).order("created_at DESC")	              
		#	render :json => {
		#										:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
		#									}

				###############   When User is Logged In but zip code is not present   ###############
		#if params[:app_user_id].present? && params[:zip_code].blank? && params[:category].blank? && params[:state].blank?
		#	@app_user = AppUser.find_by_id(params[:app_user_id])
		#	@zip_code = @app_user.zip
		#  #@service_preferences = @app_user.service_preferences.order("created_at DESC") if @app_user.present?
		#  if @app_user.present? && @zip_code.present?
		#  	@service_preferences = @app_user.service_preferences.order("created_at DESC")
		#  	@servicelist = @service_preferences.map do |sp|
		#  		@advertisement = []
		#  		@best_deal = []
		#  		@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND zip = ? AND end_date > ?", true, sp.service_category_id, @zip_code, Date.today).order("price ASC").first
		#  		@best_deal << @b_deal if @b_deal.present?
		#  		@adv = sp.service_category.advertisements.order("created_at DESC").first
		#  		@advertisement << @adv if @adv.present?
		#  		sp.service_category.service_providers.map do |pp|
		#  			if pp.is_preferred == true
		#  				@preferred_deal = []
		#  				@p_deal = Deal.where("is_active = ? AND service_category_id = ? AND service_provider_id = ? AND zip = ? AND end_date > ?", true, pp.service_category_id, pp.id, @zip_code, Date.today).order("price ASC").first
		#					@preferred_deal << @p_deal
		#				else
		#					@preferred_deal = []
		#  			end
		#  		end	
		#			{ :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		#  	end	
		#  elsif @app_user.present? && @zip_code.blank?
		#  	@service_preferences = @app_user.service_preferences.order("created_at DESC")
		#  	@servicelist = @service_preferences.map do |sp|
		#  		@advertisement = []
		#  		@best_deal = []
		#  		@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		#  		@best_deal << @b_deal if @b_deal.present?
		#  		@adv = sp.service_category.advertisements.order("created_at DESC").first
		#  		@advertisement << @adv if @adv.present?
		#  		sp.service_category.service_providers.map do |pp|
		#  			if pp.is_preferred == true
		#  				@preferred_deal = []
		#  				@p_deal = Deal.where("is_active = ? AND service_category_id = ? AND service_provider_id = ? AND end_date > ?", true, pp.service_category_id, pp.id, Date.today).order("price ASC").first
		#					@preferred_deal << @p_deal
		#				else
		#					@preferred_deal = []
		#  			end
		#  		end	
		#			{ :contract_fee => sp.price, :service_provider_name => sp.service_provider.name, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		#  	end	
		#  end
		#	render :json => { :dashboard_data => @servicelist }
		