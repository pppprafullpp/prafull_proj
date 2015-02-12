class UsersController < ApplicationController
  skip_before_filter :authenticate_user!, :only => [:reset_password, :set_reset_password]
  load_and_authorize_resource

  def index
    @users = User.all
  end
  
  def new
    @user = User.new
  end

  def create
    #params[:user][:audit_comment] = "User with email #{params[:user][:email]} has been created."
    @user = User.new(params[:user])
    @user.password_updated_at = Date.today 
    
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

  def show
    redirect_to edit_user_path
  end

  def edit
    @user = User.find(params[:id])
  end

  def edit_password
    @user = User.find(params[:id])
  end
  


  def destroy
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to users_path, :notice => 'You have successfully removed a user' }
        format.xml  { render :xml => @user, :status => :created, :user => @user }
      end
    end
    
  end
  
end
