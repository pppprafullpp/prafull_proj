####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	include DashboardsHelper
  before_action :verify_token
	skip_before_filter :verify_authenticity_token
	respond_to :json


	def index
		###############   When User is Logged In and zip code is present   ###############
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
			dashboard_data = get_dashboard_deals(params[:app_user_id],nil,nil)
			if dashboard_data == false
				render :json => { :success => false }
			else

				render :json => { :dashboard_data => dashboard_data }
			end

			###############   When User is not logged in and zip code is present   ###############
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
			dashboard_data = get_dashboard_deals(nil,params[:zip_code],params[:deal_type])
			if dashboard_data == false
				render :json => { :success => false }
			else
				render :json => { :dashboard_data => dashboard_data }
			end
			###############  Filtering  ###############
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].present? && params[:sorting_flag].present?

			allowed_deals=filtered_deals(nil,params[:category],params[:zip_code],params[:deal_type],params[:sorting_flag])

			render :json => {:deal => allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:effective_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])}

		elsif params[:app_user_id].present? && params[:zip_code].present? && params[:deal_type].blank? && params[:category].present? && params[:sorting_flag].present?

			allowed_deals=filtered_deals(params[:app_user_id],params[:category],nil,nil,params[:sorting_flag])

			render :json => {:deal => allowed_deals.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:effective_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])}
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

	def validate_business_name
		if params[:business_type].present? and params[:business_name].present? and (params[:ssn].present? || params[:federal_number].present?)
			if params[:business_type].to_i == Business::SOLE_PROPRIETOR
				business = Business.where("business_name = ? or ssn = ?",params[:business_name],params[:ssn]).first
				if business.present?
					render :json => { :success => false,:message => 'Business with this name or SSN already exists, Please enter valid information.' }
				else
					render :json => { :success => true }
				end
			elsif params[:business_type].to_i == Business::REGISTERED
				business = Business.where("business_name = ? or federal_number = ?",params[:business_name],params[:federal_number]).first
				if business.present?
					render :json => { :success => false,:business => business,:message => "We found Business #{params[:business_name]} with Federal Tax No: #{params[:federal_number]} is already registered with us, do you want to add yourself in this business." }
				else
					render :json => { :success => true }
				end
			end
		else
			render :json => { :success => false,:message => 'Insufficient Parameters' }
		end
	end

	protected
	def verify_token
		if params[:device_id].present? and params[:token].present?
			 saved_token=DeviceRegister.find_by_device_id(params[:device_id]).token
				 if saved_token!=params[:token]
					 raise "{message:'invalid token'}".to_json
				 end
		end
	end
end
