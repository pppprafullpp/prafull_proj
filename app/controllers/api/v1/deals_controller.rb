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
	  		render :json => { 
													:deals   => @deals.as_json(:include => :ratings),
												} 
			#end								
		else
			render :status => 401,
							:json => { :success => false }									
	  end	
	end  

end