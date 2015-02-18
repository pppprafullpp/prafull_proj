class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:reset_password, :set_reset_password]
  #before_action :user_params, :only => [:create]
  load_and_authorize_resource

  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    respond_to do |format|
      if @user.save
        format.html { redirect_to users_path, :notice => 'You have successfully created a user' }
        format.xml  { render :xml => @user, :status => :created, :user => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to users_path, notice: 'You have successfully updated a user.' }
        format.xml  { render :xml => @user, :status => :created, :user => @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:name,:email,:password,:password_confirmation,:role,:password_updated_at,:enabled)
  end
  
end
