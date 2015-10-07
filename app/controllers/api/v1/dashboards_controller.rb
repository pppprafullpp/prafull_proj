####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		###############   When User is Logged In but zip code is not present   ###############
		if params[:app_user_id].present? && params[:zip_code].blank? && params[:category].blank? && params[:state].blank?
			@app_user = AppUser.find_by_id(params[:app_user_id])
		  @service_preferences = @app_user.service_preferences.order("created_at DESC") if @app_user.present?
		  @servicelist = @service_preferences.map do |sp|
		  	@advertisement = []
		  	@best_deal = []
		  	@b_deal = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, sp.service_category_id, Date.today).order("price ASC").first
		  	@best_deal << @b_deal if @b_deal.present?
		  	@adv = sp.service_category.advertisements.order("created_at DESC").first
		  	@advertisement << @adv if @adv.present?
		  	sp.service_category.service_providers.map do |pp|
		  		if pp.is_preferred == true
		  			@preferred_deal = []
		  			@p_deal = Deal.where("is_active = ? AND service_category_id = ? AND service_provider_id = ? AND end_date > ?", true, pp.service_category_id, pp.id, Date.today).order("price ASC").first
						@preferred_deal << @p_deal
					else
						@preferred_deal = []
		  		end
		  	end	
				{ :contract_fee => sp.contract_fee, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  end	
			render :json => { :dashboard_data => @servicelist }
		###############   When User is Logged In and zip code is present   ###############	
		elsif params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:state].blank?											                	
			@app_user = AppUser.find_by_id(params[:app_user_id])
		  @service_preferences = @app_user.service_preferences.order("created_at DESC") if @app_user.present?
		  @servicelist = @service_preferences.map do |sp|
		  	@advertisement = []
		  	@best_deal = []
		  	@b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, params[:zip_code], sp.service_category_id, Date.today).order("price ASC").first
		  	@best_deal << @b_deal if @b_deal.present?
		  	@adv = sp.service_category.advertisements.order("created_at DESC").first
		  	@advertisement << @adv if @adv.present?
		  	sp.service_category.service_providers.map do |pp|
		  		if pp.is_preferred == true
		  			@preferred_deal = []
		  			@p_deal = Deal.where("is_active = ? AND service_category_id = ? AND service_provider_id = ? AND end_date > ?", true, pp.service_category_id, pp.id, Date.today).order("price ASC").first
						@preferred_deal << @p_deal
					else
						@preferred_deal = []
		  		end
		  	end	
				{ :contract_fee => sp.contract_fee, :service_category_name => sp.service_category.name, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
		  end	
			render :json => { :dashboard_data => @servicelist }
		###############   When only Zip Code is present   ###############
		elsif params[:zip_code].present? && params[:category].blank? && params[:app_user_id].blank? && params[:state].blank?
			@service_categories = ServiceCategory.all
			@servicelist = @service_categories.map do |sc|
				@sc_id = sc.id
				@advertisement = []
				@adv = sc.advertisements.order("created_at DESC").first
				@advertisement << @adv if @adv.present?
        	@best_deal = []
        	@b_deal = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, params[:zip_code], @sc_id, Date.today).order("price ASC").first
       		if @b_deal.present?
       			@best_deal << @b_deal
       		else
       			@best_deal = []
       		end		
        @preferred_deal = []
				{ :service_category_name => sc.name, :contract_fee => '0', :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 	
			end	
			render :json => { :dashboard_data => @servicelist	}
		###############   When only Service Category is present   ###############
		elsif params[:category].present? && params[:app_user_id].blank? && params[:zip_code].blank? && params[:state].blank?
			@deals = Deal.where("is_active = ? AND service_category_id = ? AND end_date > ?", true, params[:category], Date.today).order("created_at DESC")	              
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}
		###############   When ServiceCategory and ZipCode both are present   ###############
		elsif params[:zip_code].present? && params[:category].present? && params[:app_user_id].blank? && params[:state].blank?
			@deals = Deal.where("is_active = ? AND zip = ? AND service_category_id = ? AND end_date > ?", true, params[:zip_code], params[:category], Date.today).order("price ASC")
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}
		###############   WHen State is present   ###############
		elsif params[:state].present? && params[:category].blank? && params[:app_user_id].blank? && params[:zip_code].blank?
			@service_categories = ServiceCategory.all
			@servicelist = @service_categories.map do |sc|
				@sc_id = sc.id
				@advertisement = []
				@adv = sc.advertisements.order("created_at DESC").first
				@advertisement << @adv if @adv.present?
        	@best_deal = []
        	@b_deal = Deal.where("is_active = ? AND state = ? AND service_category_id = ? AND end_date > ?", true, params[:state], @sc_id, Date.today).order("price ASC").first
       		if @b_deal.present?
       			@best_deal << @b_deal
       		else
       			@best_deal = []
       		end		
        @preferred_deal = []
				{ :service_category_name => sc.name, :contract_fee => '0', :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 	
			end	
			render :json => { :dashboard_data => @servicelist	}
		end                
	end
end