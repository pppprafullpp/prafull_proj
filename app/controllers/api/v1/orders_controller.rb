class Api::V1::OrdersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json


	def create
		user_type = params[:app_user][:user_type].present? ? params[:app_user][:user_type] : nil
		if [AppUser::RESIDENCE,AppUser::BUSINESS].include?(user_type)
			order = Order.new(order_params)
			order.order_id=rand(36**8).to_s(36).upcase
			if order.save
				order_items = OrderItem.create_order_items(params,order.id)
				app_user = AppUser.update_app_user(params,order.app_user_id)
				if user_type == AppUser::BUSINESS
					business = Business.create_business(params)
					business_addresses = BusinessAddress.create_business_addresses(params,business.id)
					business_user = BusinessAppUser.create_business_app_user(business.id,app_user.id)
					render :status => 200,:json => {:success => true,:order => order.as_json,:order_items => order_items.as_json,:app_user => app_user.as_json,:business => business.as_json,:business_addresses => business_addresses.as_json}
				else
					app_user_addresses = AppUserAddress.create_app_user_addresses(params,app_user.id)
					render :status => 200,:json => {:success => true,:order => order.as_json,:order_items => order_items.as_json,:app_user => app_user.as_json,:app_user_addresses => app_user_addresses.as_json}
				end
			else
				render :status => 401,
							 :json => { :success => false ,:message => order.errors.full_messages}
			end
		else
			render :status => 401,
						 :json => { :success => false ,:message => 'Invalid Parameters'}
		end
	end

	def create_bck
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
		app_user = AppUser.where(:id => params[:app_user_id]).first
		if app_user.present? and app_user.user_type == AppUser::BUSINESS
			business = BusinessAppUser.where(:app_user_id => params[:app_user_id]).first
			app_user_id = business.present? ? BusinessAppUser.where(:business_id => business.id).pluck(:app_user_id) : []
		else
			app_user_id = [params[:app_user_id]]
		end
		@orders = Order.where("app_user_id = ?",app_user_id).order("id DESC")

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
			app_user = AppUser.where(:id => params[:app_user_id]).first
			deals = Deal.where(:id => params[:deal_ids].split(','))
			if app_user.user_type == AppUser::BUSINESS
				business = BusinessAppUser.select('businesses.*').joins(:business).where(:app_user_id => app_user.id).first
				render :status => 200,
							 :json => {
									 :success => true,
									 :app_users => app_user.as_json(:except => [:created_at, :updated_at]),
									 :business => business.present? ? business.as_json(:except => [:created_at, :updated_at]) : {},
									 :business_addresses => business.present? ? business.business_addresses.as_json(:except => [:created_at, :updated_at]) : [],
									 :deals => deals.as_json(:except => [:created_at, :updated_at])
							 }
			else
				render :status => 200,
							 :json => {
									 :success => true,
									 :app_users => app_user.as_json(:except => [:created_at, :updated_at]),
									 :app_user_addresses => app_user.app_user_addresses.as_json(:except => [:created_at, :updated_at]),
									 :deals => deals.as_json(:except => [:created_at, :updated_at])
							 }
			end
		else
			render :json => { :success => false }
		end
	end

	private
	def order_params
		params.require(:order).permit(:order_id,:deal_id,:app_user_id,:status,:deal_price,:effective_price,:activation_date,:order_type)
	end

end

