class Api::V1::DealsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json


	def index
		if params[:zip_code].present? && params[:category].blank?
			@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).order("price DESC")
		elsif params[:category].present? && params[:zip_code].blank?
			@deals = Deal.where("is_active = ?", true).where(service_category_id: params[:category]).order("price DESC")
		elsif params[:zip_code].present? && params[:category].present?
			@deals = Deal.where("is_active = ?", true).where(zip: params[:zip_code]).where(service_category_id: params[:category]).order("price ASC")
		end
		if @deals.present?
			#@deals.each do |deal|
			render :json => { :deals   => @deals.as_json(:include => :ratings),}
			#end
		else
			render :status => 401,:json => { :success => false }
		end
	end

	def compare_deals
		if params[:deal_id_first].present? && params[:deal_id_second].present?
			deal_1 = Deal.find(params[:deal_id_first])
			deal_2 = Deal.find(params[:deal_id_second])
			deal_1 = deal_1.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments,:deal_attributes])
			deal_2 = deal_2.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments,:deal_attributes])
			render :status => 200,:json => { :success => true, deal_1: deal_1, deal_2: deal_2 }
		end
	end

	def service_deal_config
		key = ServiceDealConfig.first.show_deal_name
		render :status => 200,:json => { :success => true, show_deal_name: key }
	end

	def password_complicated_setting
		key = ServiceDealConfig::where(config_key: "password_complicated").first.config_value
		if key.present?
		render :status => 200,:json => { :success => true, key: key }
		else
			render :status => 401,:json => { :success => false }
		end
	end

	def get_deal_channels
		deal_id = params[:deal_id]
		cable_deal_attribute = CableDealAttribute.where(:deal_id => deal_id).last
		channel_ids = cable_deal_attribute.channel_ids.present? ? eval(cable_deal_attribute.channel_ids) : []
		channels_list_record = Channel.where(id: channel_ids)
		channel_categories = channels_list_record.pluck(:category_name).uniq
		channels= []
		channel_categories.each do |category_name|
			channels_list = []
			channels_hash = {}
			channels_hash['category_name'] = category_name
			category_channels = channels_list_record.where(category_name: category_name)
			channels_hash['channel'] = category_channels
			channels << channels_hash
		end
		render :json => { :channels   => channels.as_json}
	end

	def get_channel_details
		channel_id = params[:channel_id]
		channel = Channel.find_by_id(channel_id)
		render :json => { :channel => channel.as_json}
	end

	def get_estimated_bandwidth
		bandwidth_in_mb,bandwidth_in_gb = BandwidthCalculatorSetting.calculate_bandwidth(params)
		matching_deal_id=InternetDealAttribute.where(:download=>(bandwidth_in_mb)/100).pluck(:deal_id).first
		upper_range=(bandwidth_in_mb)/1000
		lower_range=((bandwidth_in_mb)/1000)/2
		puts upper_range
		puts lower_range
			deal_name =[]
		deals=InternetDealAttribute.where("download > ? and download < ?",lower_range,upper_range).pluck(:deal_id)
		deals.each do |d|
			deal_name << Deal.find(d).title
		end
		render :json => { :bandwidth_in_mb => bandwidth_in_mb.to_s,:bandwidth_in_gb => bandwidth_in_gb.to_f.round, :matching_deal_id=>deals, :deal_name=>deal_name}
	end

	def fetch_deal_details
		if params[:deal_id].present?
			deal = Deal.find(params[:deal_id])
			     render :status => 200,
							 :json => {
									 :success => true,
									 :deals => deal.as_json(:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments],:include => ['bundle_deal_attributes','bundle_equipments'])
							 }
		else
			render :json => { :success => false}
		end
	end

	def cellphone_equipments
		app_user = AppUser.find_by_id(params[:app_user_id])
		deal = Deal.find_by_id(params[:deal_id])
		if app_user.present? && deal.present? && deal.service_category_id == Deal::CELLPHONE_CATEGORY
      if deal.cellphone_equipments.present?
        equipments =deal.cellphone_equipments.select('id,model, price')
       	render :json => { :success => true, equipments: equipments.as_json(:except=>[:id])}
      else
        render :json => { :success => false}
      end
    else
    	render :json => { :success => false}
    end
	end

	def customisable_deals
		deals = Deal.where('is_customisable =? ', true)
		render :json => { :success => true, deals: deals.as_json(:methods => [:service_category_name, :service_provider_name])}
	end

	def cellphone_details
		cellphone_detail=CellphoneDetail.select('id,cellphone_name')

	render :json=>{
	 :cellphone_details=>cellphone_detail
   }
	end

	def channel_customisable_deals
		deals = Deal.where('is_customisable =? AND service_category_id=?', true,Deal::CABLE_CATEGORY)
		# deals = Deal.find(171)
		if deals.present?
		render :json => { :success => true, deals: deals.as_json(:include =>{:channel_packages => {:methods=>[:channel_name]},:deal_attributes => {:methods => [:channel_name]},:deal_extra_services => {:methods => [:service_name,:service_description]}},:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])}
		else
			render :json => { :success => false}
		end
	end

	def customisable_deal_deatail

if params[:deal_id].present?
			deal = Deal.find(params[:deal_id])
			if deal.service_category_id == Deal::CABLE_CATEGORY
				render :json => { :success => true, deals: deal.as_json(:include =>{:channel_packages => {:methods=>[:channel_name]},:deal_attributes => {:methods => [:channel_name]},:deal_extra_services => {:methods => [:service_name,:service_description]}},:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_equipments])}
			elsif deal.service_category_id == Deal::CELLPHONE_CATEGORY

			 render :json => { :success => true, deals: deal.as_json(:include =>{:deal_equipments =>{:except=>[:available_colors],:methods => [:available_color,:cellphone_name,:brand,:description,:image]},:deal_extra_services => {:methods => [:service_name,:service_description]} },:except => [:created_at, :updated_at, :image, :price],:methods => [:deal_image_url, :average_rating, :rating_count, :deal_price,:service_category_name, :service_provider_name,:deal_additional_offers,:deal_attributes])}
			else
				render :json => { :success => false}
			end
		else
			render :json => { :success => false}
end






end
end
