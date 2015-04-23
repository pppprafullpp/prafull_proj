class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index													                	
		if params[:zip_code].present? && params[:category].blank? && params[:app_user_id].blank?
			@service_categories = ServiceCategory.all
			@servicelist = @service_categories.map do |sc|
				@advertisement = []
				@adv = sc.advertisements.order("created_at DESC").first
				@advertisement << @adv if @adv.present?
				sc.service_providers.map do |pp|
					if pp.is_preferred == false
						@best_deal = []
						#@b_deal = pp.deals.where("zip = ?", params[:zip_code]).order("price ASC").first
						@b_deal = Deal.where("is_active = ?", true).where("zip = ?", params[:zip_code]).where("service_category_id = ?", sc.id ).where("service_provider_id = ?", pp.id ).order("price ASC").first
						if @b_deal.present?
							@best_deal << @b_deal 
						else
							@best_deal = []
						end	
					elsif pp.is_preferred == true
						if @b_deal.present? && @b_deal.service_category_id != pp.service_category_id
							@b_deal = nil
							@best_deal = []
						end	
						@preferred_deal = []
						@p_deal = Deal.where("is_active = ?", true).where("zip = ?", params[:zip_code]).where("service_category_id = ? AND service_provider_id = ?", pp.service_category_id, pp.id).order("price ASC").first
						if @p_deal.present?
							@preferred_deal << @p_deal 
					  else 
						  @preferred_deal = []
						end 
					else
						 @advertisement = []
						 @best_deal = []
						 @preferred_deal = []
					end			
				end	
				{ :service_category_name => sc.name, :contract_fee => 0, :advertisement => @advertisement.as_json(:except => [:created_at, :updated_at, :image], :methods => [:advertisement_image_url]), :best_deal => @best_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]), :preferred_deal => @preferred_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 	
			end	
			render :json => { :dashboard_data => @servicelist	}

		elsif params[:category].present? && params[:app_user_id].blank? && params[:zip_code].blank?
			@deals = Deal.where("is_active = ?", true).where(service_category_id: params[:category]).order("price ASC")	              
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}

		elsif params[:zip_code].present? && params[:category].present? && params[:app_user_id].blank?
			@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).where(service_category_id: params[:category]).order("price ASC")
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}
		end                
	end
end