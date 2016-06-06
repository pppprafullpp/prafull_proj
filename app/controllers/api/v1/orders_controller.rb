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
			@gift = Gift.find_by_activation_count_condition(@orders_count)
			@gift_id = @gift.try(:id)
			if @gift_id.present? && @order.present?
				@user_gifts = @order.user_gifts.create(gift_id: @gift_id, app_user_id: params[:app_user_id])
				@gift_amount = @gift.amount
				@app_user.total_amount = @app_user.total_amount + @gift_amount
				@app_user.save
				@message = "You have won $#{@gift_amount} gift card."
				@message_status = true
			else 
				@last_gift_activation_count = @app_user.gifts.last.try(:activation_count_condition)
				@next_gift_activation_count = Gift.all.where("activation_count_condition > ?", @last_gift_activation_count ).limit(1).first.activation_count_condition rescue nil
				if @next_gift_activation_count.present?
					@message_count = @next_gift_activation_count - @orders_count 
					@message = "Please include #{@message_count} more service in your order"
					@message_status = true
				else
					@message = "There are no Gifts"
					@message_status = false
				end
			end
			@order_message = "for switching #{@orders_count} service using ServiceDeals"
			@gifts = Gift.all
    	render :status => 200,:json => {:success => true,:order_message => @order_message, :message => @message,:message_status => @message_status,:gifts => @gifts.as_json(:methods => :gift_image_url, :except => :image)}
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
		@orders = Order.where("app_user_id = ?", params[:app_user_id]).order("id DESC")

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

	def fetch_user_and_deal_details
		if params[:app_user_id].present? and params[:deal_ids].present?
			app_user = AppUser.where(:id => params[:app_user_id])
			deals = Deal.where(:id => params[:deal_ids].split(','))
			render :status => 200,
						 :json => {
								 :success => true,
								 :app_users => app_user.as_json({:include => :app_user_addresses}),
								 :deals => deals.as_json(:except => [:created_at, :updated_at])
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

