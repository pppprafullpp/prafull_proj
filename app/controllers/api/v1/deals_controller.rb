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
		channels= []
		Channel::CATEGORIES.each do |category_name|
			channels_list = []
			channels_hash = {}
			channels_hash['category_name'] = category_name
			category_channels = Channel.where(:id => channel_ids).where(category_name: category_name)
			channels_hash['channel'] = category_channels
			#channels_list << channels_hash
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
		matching_deal_id=InternetDealAttribute.where(:download=>bandwidth_in_gb).pluck(:deal_id).first
		render :json => { :bandwidth_in_mb => bandwidth_in_mb.to_s,:bandwidth_in_gb => bandwidth_in_gb.to_s, :matching_deal_id=>matching_deal_id}
	end
end
