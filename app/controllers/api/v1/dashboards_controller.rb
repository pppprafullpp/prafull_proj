class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@deals = []
		@preferred_deals = []
		@advertisements = []
		if params[:app_user_id].present?
			@app_user = AppUser.find_by_id(params[:app_user_id])
		  @service_preferences = @app_user.service_preferences if @app_user.present?
			@service_preferences.each do |sp|
				@sc_id = sp.service_category_id
				@advertisement = Advertisement.where("service_category_id = ?", @sc_id).first
				@advertisements << @advertisement
				if sp.service_provider.is_preferred == true
					@sp_id = sp.service_provider.id
					@p_deal = Deal.where("is_active = ?", true).where("service_category_id = ?", @sc_id).where("service_provider_id = ?", @sp_id).order("price ASC").first
					@preferred_deals << @p_deal
				elsif sp.service_provider.is_preferred == false
					@sc_deal = Deal.where("is_active = ?", true).where("service_category_id = ?", @sc_id).order("price ASC").first
					#unless @deals.include?(@sc_deal)
						@deals << @sc_deal
					#end	
				end	
			end	
			render :json => { 
												#:app_user => @app_user.as_json(:include => { :service_preferences => { :include => { :service_category => { :include => { :deals => { :only => [:id, :title]}}, :only => [:id, :name]}}, :only => [:service_category_id, :service_provider_id, :contract_fee]}}),
												#:service_preference => @service_preferences.as_json(:include => { :service_category => { :include => :deals, :include => :advertisement }})
												#********** Working **************
												:service_preference => @service_preferences.as_json(:include => { :service_category => {:only => [:id, :name]}}, :only => [:id, :contract_fee] ),
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :deal_price]),
												:preferred_deal => @preferred_deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :deal_price]),
		                		:advertisement => @advertisements.as_json(:methods => [:ad_image_url])
		                	}
		elsif params[:zip_code].present? && params[:category].blank? 
			@service_categories = ServiceCategory.all
			@service_preference = []
			@service_categories.each do |sc|
				@advertisement = Advertisement.where("service_category_id = ?", sc.id).first
				@advertisements << @advertisement	
				sc.service_providers.each do |sp|
					if sp.is_preferred == true
						sp_id = sp.id
						#@p_deals = Deal.where("is_active = ?", true).where("service_category_id = ?",sc.id).where("zip = ?", params[:zip_code]).order("price ASC").limit(1)
						@p_deal = Deal.where("is_active = ?", true).where("service_category_id = ? AND service_provider_id = ?", sc.id, sp_id).where("zip = ?", params[:zip_code]).order("price ASC").first
						@preferred_deals << @p_deal
					elsif sp.is_preferred == false
						@sc_deal = Deal.where("is_active = ?", true).where("service_category_id = ?", sc.id).where("zip = ?", params[:zip_code]).order("price ASC").first
				    unless @deals.include?(@sc_deal)
   						@deals << @sc_deal
						end
					end			
				end		
			end	
			render :json => { 
												:service_preference => @service_preference, 
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :deal_price]),
												:preferred_deal => @preferred_deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :deal_price]),
												:advertisement => @advertisements.as_json(:methods => [:ad_image_url])
											}
		elsif params[:category].present? && params[:zip_code].blank?
			@deals = Deal.where("is_active = ?", true).where(service_category_id: params[:category]).order("price ASC")	              
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price])
											}
		elsif params[:zip_code].present? && params[:category].present? 
			@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).where(service_category_id: params[:category]).order("price ASC")
			render :json => {
												:deal => @deals.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count])
											}
		end                
	end
end