class Api::V1::NotificationsController < ApplicationController
	skip_before_filter :verify_authenticity_token
	respond_to :json

	def new
		@notification = Notification.new
	end

  def fetch_notification
    @notification = Notification.find_by_app_user_id(params[:app_user_id])
    if @notification.present?
      render :status => 200,
             :json => {
                        :success => true,
                        :notification => @notification.as_json(:except => [:created_at, :updated_at])
                      }
    else
      render :json => { :success => false }
    end  
  end

	def create
		@notification = Notification.find_by_app_user_id(params[:app_user_id])
		if @notification.present?
			#respond_to do |format|
      		if @notification.update(notification_params)
        		#format.json { success: :true }
        		render :status => 200,
           			:json => { :success => true }
      		else
        		render :status => 401,
           		:json => { :success => false }	
        	end
    		#end
		else
			@notification = Notification.new(notification_params) 
			#raise service_preference_params.inspect   
    		#respond_to do |format|
      		if @notification.save
      			#format.json { render json: @service_preference, status: :created }
        		#format.xml { render xml: @service_preference, status: :created }
        		render :status => 200,
           		:json => { :success => true }
      		else
        		#format.json { render json: @user.errors}
        		render :status => 401,
           		:json => { :success => false }
      		end
    		#end
		end
	end

	private
	def notification_params
		params.permit(:app_user_id, :recieve_notification, :day)
	end

end	