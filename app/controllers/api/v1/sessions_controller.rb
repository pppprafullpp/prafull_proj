class Api::V1::SessionsController < Devise::SessionsController
  skip_before_filter :verify_authenticity_token,
                     :if => Proc.new { |c| c.request.format == 'application/json' }

  
  respond_to :json

  def create
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged in",
                      :data => {} 
                    }
  end

  def destroy
    warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#failure")
    current_user.update_column(nil)
    render :status => 200,
           :json => { :success => true,
                      :info => "Logged out",
                      :data => {} }
  end

  def failure
    render :status => 401,
           :json => { :success => false,
                      :info => "Login Failed",
                      :data => {} }
  end

  #def create
  #  app_user = AppUser.authenticate(params[:email], params[:password])
  #  if app_user
  #    session[:app_user_id] = app_user.id
  #    render :status => 200,
  #         :json => { :success => true,
  #                    :info => "Logged in",
  #                    :data => {} 
  #                  }
  #  else
  #    render :status => 401,
  #         :json => { :success => false,
  #                    :info => "Login Failed",
  #                    :data => {} 
  #                  }
  #  end
  #end

end