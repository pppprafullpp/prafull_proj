class Api::V1::OrdersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def create
		@order = Order.new(order_params) 
		@order.activation_start_date = Time.now
		if @order.save
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
                        :order => @order.as_json(:except => [:created_at, :updated_at])
                        
                      }
		else
			render :json => { :success => false }
		end	
	end

	private
	def order_params
		params.permit(:deal_id,:app_user_id,:status,:effective_price,:deal_price,:activation_start_date)
	end

end

