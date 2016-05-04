####################   API for showing deals on the Dashboaed   #######################

class Api::V1::DashboardsController < ApplicationController
	include DashboardsHelper

	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		###############   When User is Logged In and zip code is present   ###############	
		if params[:app_user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?											                	
			user_dashboard_deals(params[:app_user_id])
		###############   When User is not logged in and zip code is present   ###############	
		elsif params[:app_user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
			@service_categories = ServiceCategory.where("name in ('Internet','Telephone','Cellphone','Cable','Bundle')")
		  	@categoryList = @service_categories.map do |sc|
				
				trending_deal = category_trending_deal(params[:deal_type],sc.id)
		  		
		  		if trending_deal.present?
					restricted_deal=Deal.joins(:deals_zipcodes).joins(:zipcodes).where("deals_zipcodes.deal_id= ? AND zipcodes.code= ? ",trending_deal.id,params[:zip_code])
					if not restricted_deal.present?
						allowed_trending_deal=trending_deal
				    end
				end
		  		{:you_save_text => "", :contract_fee => "", :service_provider_name => allowed_trending_deal.service_provider_name, :service_category_name => allowed_trending_deal.service_category_name,:trending_deal => allowed_trending_deal.as_json(:except => [:created_at, :updated_at, :price, :image], :methods => [:deal_image_url, :average_rating, :rating_count, :deal_price]) } 
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
		