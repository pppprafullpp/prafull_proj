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
      @app_user.zip = params[:app_user][:zip_code].present? ? encode_api_data(params[:app_user][:zip_code]) : encode_api_data("75024")
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
      @app_user.address = address + '===' + address1 + '===' + address2
      #@app_user.city = params[:city];@app_user.state = params[:state]
      # first_name = params[:first_name].present? ? params[:first_name].split(' ')[0] : @app_user.first_name
      # last_name = params[:first_name].present? ? params[:first_name].split(' ')[1] : @app_user.last_name
      @app_user.first_name = encode_api_data(params[:first_name])
      @app_user.last_name = encode_api_data(params[:last_name])
      @app_user.mobile = params[:mobile]
      @app_user.primary_id = params[:primary_id]
      @app_user.primary_id_number = params[:primary_id_number]
      @app_user.secondary_id = params[:secondary_id]
      @app_user.secondary_id_number = params[:secondary_id_number]

      @app_user.user_type = params[:user_type] if params[:user_type].present?
      @app_user.avatar=params[:avatar] if params[:avatar].present?

      if @app_user.save!
        if @app_user.user_type == AppUser::BUSINESS
          if  @app_user.business_app_users.present?
            business_user_id = BusinessAppUser.find_by_app_user_id(@app_user.id).business_id
            business_addresses = BusinessAddress.find_by_business_id(business_user_id)
            business_addresses.update_attributes(
                :address_name=>params[:addresses][:address_name],
                :address_type => params[:addresses][:address_type],
                :zip=>params[:addresses][:zip],
                :address1 =>params[:addresses][:address1],
                :address2=>params[:addresses][:address2],
                :contact_number=>params[:addresses][:contact_number])
          else
            params[:business][:ssn]=encode_api_data(params[:business][:ssn]) if params[:business][:ssn].present?
            params[:business][:federal_number]=encode_api_data(params[:business][:federal_number]) if params[:business][:federal_number].present?
            @business = Business.create_business(params)
            if @business.present?
              address_hash = {:business_addresses => [params[:addresses]]}
              business_user = BusinessAppUser.create_business_app_user(@business.id,@app_user.id)
              business_addresses = BusinessAddress.create_business_addresses(address_hash,@business.id)
            end
          end
        else
          if  @app_user.app_user_addresses.present?
            app_user_address = @app_user.app_user_addresses.first
            app_user_address.update_attributes(
                :address_name=>params[:addresses][:address_name],
                :address_type => params[:addresses][:address_type],
                :zip=>params[:addresses][:zip],
                :address1 =>params[:addresses][:address1],
                :address2=>params[:addresses][:address2],
                :contact_number=>params[:addresses][:contact_number])
          else
            address_hash = {:app_user_addresses => [params[:addresses]]}
            app_user_addresses = AppUserAddress.create_app_user_addresses(address_hash,@app_user.id)
          end
        end
        flash[:notice] = 'User Updated successfully'
        redirect_to profile_website_app_users_path
      else
        flash[:warning] = @app_user.errors.full_messages
        redirect_to profile_website_app_users_path
      end
      # @app_user.update_attributes(:avatar=>params[:avatar])

    else
      redirect_to website_home_index_path
    end
  end

  def preferences
    if session[:user_id].present?

      if params[:notification][:recieve_trending_deals] == "on"
        params[:notification][:recieve_trending_deals]=true
      else
        params[:notification][:recieve_trending_deals]=false
      end

      if params[:notification][:receive_call] == "on"
        params[:notification][:receive_call]=true
      else
        params[:notification][:receive_call]=false
      end

      if params[:notification][:receive_email] == "on"
        params[:notification][:receive_email]=true
      else
        params[:notification][:receive_email]=false
      end

      if params[:notification][:receive_text] == "on"
        params[:notification][:receive_text]=true
      else
        params[:notification][:receive_text]=false
      end

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
          category_id = ServiceCategory.find_by_name(params[:id].capitalize).id
          @order_history = Order.joins("inner join order_items on order_items.order_id = orders.id inner join deals on deals.id = order_items.deal_id where app_user_id = "+session[:user_id].to_s+" and deals.service_category_id="+category_id.to_s)
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
        order = Order.new(:app_user_id => @app_user.id,:status => "new_order",:order_type => Order::TRANSACTIONAL_ORDER, :primary_id => params[:primary_id], :secondary_id => params[:secondary_id], :primary_id_number => params[:primary_id_number], :secondary_id_number => params[:secondary_id_number]  )
        order.order_id=rand(36**8).to_s(36).upcase
        params[:app_user][:first_name]=encode_api_data(params[:app_user][:first_name])
        params[:app_user][:last_name]=encode_api_data(params[:app_user][:last_name])
        if order.save
          order_item_hash = {:order_items => [params[:order_items]] }
          order_items = OrderItem.create_order_items(order_item_hash,order.id)
          app_user_hash = {:app_user => params[:app_user] }
          @app_user_update = AppUser.update_app_user(app_user_hash,order.app_user_id,order)
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
            # redirect_to website_home_index_path
          else
            app_user_addresses = AppUserAddress.create_app_user_addresses(address_hash,@app_user.id)
            OrderMailer.delay.order_confirmation(@app_user,order)
            redirect_to "/website/app_users/profile?status=new_order"
          end
        else
          # redirect_to website_home_index_path
        end
      else
        # redirect_to website_home_index_path
      end
      flash[:notice] = 'Order submitted successfully'
    end
  end

  def checkout
  end

  def user_addresses
    if params[:id].present? and AppUser.find(params[:id]).orders.present?
      @addresses=AppUser.find(params[:id]).orders.last.order_addresses
      render :json=>{
        :status=>@addresses
      }
    else
      render :json=>{
        :status=>"no addresses"
      }
    end
  end

  def order
    if session[:user_id].present?
      @app_user = AppUser.find(session[:user_id])
      @deal = Deal.find_by_id(params[:deal_id])
    else
      session[:deal] = params[:deal_id]
      redirect_to checkout_website_app_users_path
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
        session[:zip_code] = @app_user.zip
        session[:user_type] = @app_user.user_type
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
      @business = Business.select('businesses.*').joins(:business_app_users).where("business_app_users.app_user_id = ?",@app_user.id).first
    else
      redirect_to website_home_index_path
    end
  end

  def forget_password
    @app_user = AppUser.find_by_email(params[:email])
    if @app_user.present?
      @email = @app_user.email
      AppUserMailer.recover_password_email(@app_user).deliver_now
      flash[:notice] = 'You will receive your password soon in email.'
      redirect_to request.referrer and return
    else
      flash[:warning] = 'This Email is not registered with us.'
      redirect_to request.referrer and return
    end
  end

  def contact_us
    AppUserMailer.contact_us(params[:name],params[:email],params[:subject],params[:message]).deliver_now
    flash[:notice] = 'Your Request is forwarded to Service Dealz Team.'
    redirect_to request.referrer and return
  end

  private
  def app_user_params
    params.require(:app_user).permit!
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
