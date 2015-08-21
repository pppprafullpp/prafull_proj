class Api::V1::AppUsersController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def new
		@app_user = AppUser.new
	end

	def create
		@app_user = AppUser.find_by_email(params[:email])
		if @app_user.present?
			if params[:first_name].present? || params[:last_name].present? || params[:address].present? || params[:state].present? || params[:city].present? || params[:zip].present? 
        @app_user.update(app_user_params)
        		#format.json { success: :true }
        		render :status => 200,
           			:json => { :success => true }
      else
        		render :status => 401,
           		:json => { :success => false }	
      end
		else
			@app_user = AppUser.new(app_user_params) 
      @app_user.unhashed_password = params[:password]
      	if @app_user.save
        		render :status => 200,
           		:json => { :success => true, :app_user_id => @app_user.id }
      	else
        		render :status => 401,
           		:json => { :success => false }
      	end
		end	
	end

  def recover_password
    @app_user = AppUser.find_by_email(params[:email])
    @email = @app_user.email
    if @app_user.present?
      AppUserMailer.recover_password_email(@app_user).deliver_now
      render  :json => { :success => true }
    else
      render  :json => { :success => false }
    end
  end

	private
	def app_user_params
		params.permit(:first_name, :last_name, :email, :state, :city, :zip, :password, :unhashed_password, :address, :active, :avatar, :gcm_id)
	end

end	