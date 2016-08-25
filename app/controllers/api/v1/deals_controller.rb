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
		if params[:deal_id].present? && params[:category_id].to_i== Deal::BUNDLE_CATEGORY
			deal = Deal.find(params[:deal_id])
				render :status => 200,
							 :json => {
									 :success => true,
									 :deals => deal.as_json(:except => [:created_at, :updated_at],:include => ['bundle_deal_attributes','bundle_equipments'])
							 }
		else
			render :json => { :success => false}
		end
	end
end
