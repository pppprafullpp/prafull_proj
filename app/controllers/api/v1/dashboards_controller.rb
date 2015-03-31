class Api::V1::DashboardsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@app_user = AppUser.find_by_id(params[:app_user_id])
		@service_preferences = @app_user.service_preferences if @app_user.present?
		@deals = []
		@preferred_deals = []
		@advertisements = []
		if params[:app_user_id].present?
			@service_preferences.each do |sp|
				@sc_id = sp.service_category_id
				@internet_deals = Deal.where("is_active = ?", true).where("service_category_id = ?", @sc_id).order("price DESC").first
				@advertisement = Advertisement.where("service_category_id = ?", @sc_id).first
				@advertisements << @advertisement
				@deals << @internet_deals
				if sp.service_provider.is_preferred == true
					@sp_id = sp.service_provider.id
					@p_deals = Deal.where("is_active = ?", true).where("service_category_id = ?", @sc_id).where("service_provider_id = ?", @sp_id).order("price DESC").first
					@preferred_deals << @p_deals
				end	
			end	
			render :json => { 
											#:app_user => @app_user.as_json(:include => { :service_preferences => { :include => { :service_category => { :include => { :deals => { :only => [:id, :title]}}, :only => [:id, :name]}}, :only => [:service_category_id, :service_provider_id, :contract_fee]}}),
											:service_preference => @service_preferences.as_json(:include => { :service_category => { :include => { :deals => { :only => [:id, :title]}}, :only => [:id, :name]}}),
											:deal => @deals.as_json(:methods => [:deal_image_url]),
											:preferred_deal => @preferred_deals.as_json(:methods => [:deal_image_url]),
		                	:advertisement => @advertisements
		                }
		elsif params[:zip_code].present? && params[:category].blank? 
			@service_categories = ServiceCategory.all
			@service_categories.each do |sc|
				@advertisement = Advertisement.where("service_category_id = ?", sc.id).first
				@advertisements << @advertisement
				sc.service_providers.each do |sp|
					if sp.is_preferred == false
						@sc_deals = Deal.where("is_active = ?", true).where("service_category_id = ?",sc.id).where("zip = ?", params[:zip_code]).order("price DESC").first
						@deals << @sc_deals
						#@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).order("price DESC")
					elsif sp.is_preferred == true
						@sc_deals = Deal.where("is_active = ?", true).where("service_category_id = ?",sc.id).where("zip = ?", params[:zip_code]).order("price DESC").first
						@preferred_deals << @sc_deals
					else
						return false
					end			
				end			
			end									
			render :json => { 	
												:deal => @deals.as_json(:methods => [:deal_image_url]),
												:preferred_deal => @preferred_deals.as_json(:methods => [:deal_image_url]),
												:advertisement => @advertisements
											}
		elsif params[:category].present? && params[:zip_code].blank?
			@deals = Deal.where("is_active = ?", true).where(service_category_id: params[:category]).order("price DESC")	              
			render :json => {
												:deal => @deals.as_json(:methods => [:deal_image_url])
											}
		elsif params[:zip_code].present? && params[:category].present?  
			@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).where(service_category_id: params[:category]).order("price DESC")
			render :json => {
												:deal => @deals.as_json(:methods => [:deal_image_url])
											}
		end                
			#render :json => @app_user, :include => { :service_preferences => { :include => { :service_category  => { :only => [:id, :name] }}, :only => :service_category_id }}
			#render :json => @app_user, :include => { :service_preferences => {
			#																																		:include => { :service_category => { :only => [:id, :name] } },
			#																																		:only => [:service_category_id, :service_provider_id, :contract_date, :is_contract, :contract_fee]
			#																																	} 
			#																				}
			#render :json => @app_user, :include => { :service_preferences => { :include => { :service_category => { :include => {:deals => { :only => :title }}, { :only => [:id, :name] } }, :only => [:service_category_id, :service_provider_id]} }}
			#@app_user = AppUser.find_by_id(params[:app_user_id]) 
			#@service_preference = ServicePreference.where("app_user_id = ?", params[:app_user_id])
			#@app_user = AppUser.joins(:service_preferences).where("app_user_id = ?", params[:app_user_id])
			#@service_preference = @app_user.map{|c| c.service_preferences}
			#render :json => { :service_preference => @service_preferences }
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