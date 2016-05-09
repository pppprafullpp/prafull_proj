####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	include DashboardsHelper

	skip_before_filter :verify_authenticity_token
	
	respond_to :json

	def index
		###############   When User is Logged In and zip code is present   ###############	
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?											                	
			get_dashboard_deals(params[:app_user_id],nil,nil)
		
		###############   When User is not logged in and zip code is present   ###############	
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
			get_dashboard_deals(nil,params[:zip_code],params[:deal_type])
		
		###############  Filtering  ###############
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].present? && params[:sorting_flag].present?
			
			allowed_deals=filtered_deals(nil,params[:category],params[:zip_code],params[:deal_type],params[:sorting_flag])

			render :json => {:deal => allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price])}
		
		elsif params[:app_user_id].present? && params[:zip_code].present? && params[:deal_type].blank? && params[:category].present? && params[:sorting_flag].present?
			
			allowed_deals=filtered_deals(params[:app_user_id],params[:category],nil,nil,params[:sorting_flag])

			render :json => {:deal => allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:additional_offer_title,:additional_offer_detail,:additional_offer_price])}
		end
	end	

	def category_deals
		if params[:app_user_id].present? && params[:service_category_id].present? && params[:zip_code].present?
			allowed_deals=get_category_deals(params[:app_user_id],params[:service_category_id],nil,nil)
		elsif params[:app_user_id].blank? && params[:service_category_id].present? && params[:zip_code].present? && params[:deal_type].present?
			allowed_deals=get_category_deals(nil,params[:service_category_id],params[:zip_code],params[:deal_type])
		end	

		render :json => {:deal => allowed_deals}
	end
end	
		