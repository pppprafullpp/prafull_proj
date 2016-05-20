class Api::V1::OrdersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def create
		@order = Order.new(order_params)
		@order.order_id=rand(36**8).to_s(36).upcase
		@order.activation_date = Time.now  
		if @order.save
			@app_user= @order.app_user
			@orders_count = @app_user.orders.count
			@gift_id = Gift.find_by_activation_count_condition(@orders_count).try(:id)
			if @gift_id.present? && @order.present?
				@user_gifts = @order.user_gifts.create(gift_id: @gift_id, app_user_id: params[:app_user_id])
			end
			@gifts =@app_user.gifts
    	render :status => 200,
           	 :json => { 
           	          :success => true,
           	          :gifts => @gifts.as_json(:include => :orders) 
           			      }
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
		params.permit(:order_id,:deal_id,:app_user_id,:status,:deal_price,:effective_price,:activation_date)
	end

end

