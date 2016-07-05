class Website::AppUsersController < ApplicationController
  layout 'website_layout'
  def new

  end

  def create
    @app_user = AppUser.find_by_email(params[:app_user][:email]) if params[:app_user][:email].present?
    if @app_user.present?
      redirect_to website_home_index_path
    else
      @app_user = AppUser.new(app_user_params)
      @app_user.unhashed_password = params[:app_user][:password]
      @app_user.referral_code = rand(36**4).to_s(36).upcase
      @app_user.zip = 75024
      if @app_user.save!
        session[:user_id] = @app_user.id
        session[:user_name] = @app_user.first_name.present? ? @app_user.first_name : @app_user.email.split('@')[0]
        flash[:notice] = 'SignUp Successfull'
        if session[:deal].present?
          redirect_to order_website_app_users_path(:deal_id=> session[:deal])
        else
          redirect_to request.referrer
        end
      else
        flash[:warning] = @app_user.errors.full_messages
        redirect_to request.referrer
      end
    end
  end

  def edit

  end

  def update
    if session[:user_id].present?
      @app_user = AppUser.find(session[:user_id])
      address = params[:address].present? ? params[:address] : ''
      address1 = params[:address1].present? ? params[:address1] : ''
      address2 = params[:address2].present? ? params[:address2] : ''
      first_name = params[:first_name].present? ? params[:first_name].split(' ')[0] : @app_user.first_name
      last_name = params[:first_name].present? ? params[:first_name].split(' ')[1] : @app_user.last_name
      @app_user.address = address + '===' + address1 + '===' + address2
      @app_user.first_name = first_name ; @app_user.last_name = last_name
      @app_user.city = params[:city];@app_user.state = params[:state]
      if @app_user.save!
        flash[:notice] = 'User Updated successfully'
        redirect_to profile_website_app_users_path
      else
        flash[:warning] = @app_user.errors.full_messages
        redirect_to profile_website_app_users_path
      end
    else
      redirect_to website_home_index_path
    end
  end

  def preferences
    if session[:user_id].present?
      @notification = Notification.create_notification(params,session[:user_id])
      flash[:notice] = 'Preference Updated successfully'
      redirect_to profile_website_app_users_path
    end
  end

  def order_history
    if session[:user_id].present?
      app_user = AppUser.find(session[:user_id])
      @orders = app_user.try(:orders)
      @orders.each do |order|
        category = ServiceCategory.select(" distinct name").joins(:deals).where("deals.id = ?",order.order_items.first.deal_id).first.name.downcase
        if  params[:id] == category
         @order_history = app_user.try(:orders)
        elsif params[:id] == "home"
          @order_history = app_user.try(:orders)
        end
      end
    end
  end

  def create_order
    if session[:user_id].present?
      @app_user = AppUser.find(session[:user_id])
      user_type = @app_user.user_type.present? ? @app_user.user_type : nil
      if [AppUser::RESIDENCE,AppUser::BUSINESS].include?(user_type)
        order = Order.new(app_user_id: @app_user.id,status: "new_order",order_type: 0, primary_id: params[:primary_id], secondary_id: params[:secondary_id] )
        order.order_id=rand(36**8).to_s(36).upcase
        if order.save
          order_item_hash = {:order_items => [params[:order_items]] }
          order_items = OrderItem.create_order_items(order_item_hash,order.id)
          app_user_hash = {:app_user => params[:app_user] }
          @app_user_update = AppUser.update_app_user(app_user_hash,order.app_user_id)
          address_hash = {:app_user_addresses => [params[:shipping_addresses],params[:app_user_addresses],params[:service_addresses]] } if @app_user.user_type == "residence"
          address_hash = {:business_addresses => [params[:business_addresses],params[:business_shipping_addresses],params[:business_service_addresses]] } if @app_user.user_type == "business"
          order_addresses = OrderAddress.create_order_addresses(address_hash ,order.id)
          if user_type == AppUser::BUSINESS
            business_hash = {:business => params[:business] }
            business = Business.create_business(business_hash)
            if business.present?
              business_addresses = BusinessAddress.create_business_addresses(address_hash,business.id)
              business_user = BusinessAppUser.create_business_app_user(business.id,@app_user.id)
            end
            OrderMailer.delay.order_confirmation(@app_user,order)
            redirect_to profile_website_app_users_path
          else
            app_user_addresses = AppUserAddress.create_app_user_addresses(address_hash,@app_user.id)
            OrderMailer.delay.order_confirmation(@app_user,order)
            redirect_to profile_website_app_users_path
          end
        else
          redirect_to profile_website_app_users_path
        end
      else
        redirect_to profile_website_app_users_path
      end
    end
  end

  def order
    if session[:user_id].present?
      @app_user = AppUser.find(session[:user_id])
      @deal = Deal.find_by_id(params[:deal_id])
    else
      session[:deal] = params[:deal_id]
      redirect_to order_website_app_users_path
    end
  end

  def order_detail
    @order = Order.find_by_id(params[:order_id].to_i)
  end

  def signin
    if request.method.eql? 'POST'
      @app_user = AppUser.authenticate(params[:user][:email], params[:user][:password])
      if @app_user.present?
        session[:user_id] = @app_user.id
        session[:user_name] = @app_user.first_name.present? ? @app_user.first_name : @app_user.email.split('@')[0]
        flash[:notice] = 'Signin Successfull'
        if session[:deal].present?
          redirect_to order_website_app_users_path(:deal_id=> session[:deal])
        else
          redirect_to website_home_index_path
        end
      else
        flash[:warning] = 'Incorrect Username or Password!'
        redirect_to request.referrer and return
      end
    else
      redirect_to website_home_index_path
    end
  end

  def signout
    reset_session
    redirect_to website_home_index_path and return
  end

  def check_user_email_ajax
    email = params[:email]
    user = AppUser.select('email').where(:email => email) if email.present?
    user = user.first if user.present?
    respond_to do |format|
      format.html {render :nothing => true }
      format.js { render :json => { :data => user, :layout => false}.to_json}
    end
  end

  def profile
    if session[:user_id].present?
      @app_user = AppUser.find(session[:user_id])
      # @orders = @app_user.orders
      # @orders = Order.select("orders.*,order_items.deal_id,order_items.deal_price,order_items.effective_price").joins(:order_items).where(:app_user_id => session[:user_id]).order("id DESC")
    else
      redirect_to website_home_index_path
    end
  end

  private
  def app_user_params
    params[:avatar] = decode_picture_data(params[:picture_data]) if params[:picture_data].present?
    params.require(:app_user).permit(:user_type,:business_name,:first_name, :last_name, :email, :state, :city, :zip, :password, :unhashed_password, :address, :active, :avatar, :gcm_id, :device_flag,:referral_code,:refer_status)
  end

  # def order_params
  #   params.require(:order).permit(:order_id,:deal_id,:app_user_id,:status,:deal_price,:effective_price,:activation_date,:order_type,:order_number,:security_deposit,:primary_id,:secondary_id)
  # end

  def decode_picture_data(picture_data)
    # decode the base64
    data = StringIO.new(Base64.decode64(picture_data))

    # assign some attributes for carrierwave processing
    data.class.class_eval { attr_accessor :original_filename, :content_type }
    data.original_filename = "upload.png"
    data.content_type = "image/png"

    # return decoded data
    data
  end

  
end