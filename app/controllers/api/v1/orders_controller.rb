class Api::V1::OrdersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def create
		@order = Order.new(order_params) 
		if @order.save
			@order.gift_orders.create(gift_id: params[:gift_id])
    	render :status => 200,
           			:json => { :success => true }
    else
      render :status => 401,
      					:json => { :success => false }
    end
	end

	def get_orders
		@order = Order.where("id = ?", params[:id])
		if @order.present?
			render :status => 200,
             :json => {
                        :success => true,
                        :orders => @order.as_json(:except => [:created_at, :updated_at])
                        
                      }
		else
			render :json => { :success => false }
		end	
	end

	def my_orders
		@orders = Order.where("app_user_id = ?", params[:app_user_id])
		if @orders.present?
      	render :status => 200,
             :json => {
                      :success => true,
                      :order => @orders.as_json(:include => {:deal => {:methods => :deal_image_url}},:methods => :order_place_time)
                      }
                     
    else
      render :json => { :success => false }
    end  
	end

	private
	def order_params
		params.permit(:deal_id,:app_user_id,:status,:deal_price,:effective_price,:activation_date)
	end

end

