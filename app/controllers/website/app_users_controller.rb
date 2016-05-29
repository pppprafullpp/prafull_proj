class Website::AppUsersController < ApplicationController

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
      if @app_user.save!
        session[:user_id] = @app_user.id
        session[:user_name] = @app_user.first_name.present? ? @app_user.first_name : @app_user.email.split('@')[0]
        flash[:notice] = 'SignUp Successfull'
        redirect_to request.referrer
      else
        flash[:warning] = @app_user.errors.full_messages
        redirect_to request.referrer
      end
    end
  end

  def edit

  end

  def update

  end

  def signin
    if request.method.eql? 'POST'
      @app_user = AppUser.authenticate(params[:user][:email], params[:user][:password])
      if @app_user.present?
        session[:user_id] = @app_user.id
        session[:user_name] = @app_user.first_name.present? ? @app_user.first_name : @app_user.email.split('@')[0]
        flash[:notice] = 'Signin Successfull'
        redirect_to website_home_index_path
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

  private
  def app_user_params
    params[:avatar] = decode_picture_data(params[:picture_data]) if params[:picture_data].present?
    params.require(:app_user).permit(:user_type,:business_name,:first_name, :last_name, :email, :state, :city, :zip, :password, :unhashed_password, :address, :active, :avatar, :gcm_id, :device_flag,:referral_code,:refer_status)
  end

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