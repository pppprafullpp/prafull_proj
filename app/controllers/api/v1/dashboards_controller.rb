class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		#@app_user = AppUser.find_by_id(params[:app_user_id]) 
		#@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id])
		@app_user = AppUser.joins(:service_preferences).where("app_user_id = ?", params[:app_user_id])
		@service_preference = @app_user.map{|c| c.service_preferences}
		render :json => { :service_preference => @service_preference
		}
		#@service_preference.each do |variable|
		#	if variable.service_category_name == "Internet"
		#		@internet_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Internet').order("price DESC")
		#	elsif variable.service_category_name == "Telephone"
		#		@telephone_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Telephone').order("price DESC")
		#	elsif variable.service_category_name == "Cable"
		#		@cable_deal = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Cable').order("price DESC")
		#	elsif variable.service_category_name == "Cellphone"	
		#		@cellphone_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Cellphone').order("price DESC")
		#	elsif variable.service_category_name == "Gas"
		#		@gas_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Gas').order("price DESC")
		#	elsif variable.service_category_name == "Electricity"
		#		@electricity_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Electricity').order("price DESC")
		#	elsif variable.service_category_name == "Bundle"
		#		@bundle_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Bundle').order("price DESC")
		#	elsif variable.service_category_name == "Home Security"	
		#		@hs_deals = Deal.where("is_active = ?", true).where("service_category_name = ?", 'Home Security').order("price DESC")
		#	end
		#end
		#if @app_user.present?
		#	render :status => 200,
    #       	 :json => { :success            => true, 
    #       	 						:app_user           => @app_user, 
    #       	 						:service_preference => @service_preference,
    #       	 						:internet_deals     => @internet_deals,
    #       	 						:telephone_deals    => @telephone_deals,
    #       	 						:cable_deals        => @cable_deals,
    #       	 						:cellphone_deals    => @cellphone_deals,
    #       	 						:gas_deals          => @gas_deals,
    #       	 						:electricity_deals  => @electricity_deals,
    #       	 						:bundle_deals       => @bundle_deals,
    #       	 						:hs_deals           => @hs_deals,
    #       	 					}
    #else
    #  render :status => 401,
    #       	 :json => { :success => false }
    #end
	end
end