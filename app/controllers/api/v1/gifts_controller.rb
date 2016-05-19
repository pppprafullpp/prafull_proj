class Api::V1::GiftsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def index
		@gifts = Gift.all
	end

	def create
	end

	def get_gifts
		if params[:app_user_id].present?
			@app_user = AppUser.find(params[:app_user_id])
			@order_count = @app_user.orders.count 
			@gift = Gift.where("activation_count_condition =?", @order_count )
			if @gift.present?
				render 	:status => 200,
		        		:json => {
		                     	:success => true,
		                      :gifts => @gift.as_json                        
		                     }
			else
				render :json => { :success => false }
			end
		else
			render :json => { :success => false }
		end
	end

	def my_gifts
	end

	private
	def order_params
		params.permit(:name, :description, :amount, :is_active, :activation_count_condition)
	end

end

 