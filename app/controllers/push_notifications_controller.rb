class PushNotificationsController < ApplicationController
	def index
		@p_notifications = PushNotification.all
	end
	def new
		@push_notification = PushNotification.new
	end
	def edit
		@p_notification = PushNotification.find(params[:id])
	end
	def create
		@push_notification = PushNotification.new(push_notification_params)   
    gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
    #byebug
    #registration_id= ["APA91bHAZB4vPEh8cvuVvMQEefI0y5eue42HldyKHJHvPEY7qP1mkY1yVNzufkz6Qw9PjHzlHvDhya-Iol2IvC28f_oHn4Oq-2xWA5-SDKxk7WR-dUgD0dX1GYM4Mb-5mNpU-huCTiVy"]
    #registration_id = @push_notification.app_user.gcm_id if @push_notification.app_user.gcm_id.present? #@app_users.map{|notice| notice.gcm_registration_id}
    registration_id = ["#{@push_notification.app_user.gcm_id}"]
    gcm.send(registration_id, {data: {message: "#{@push_notification.message}"}})
    	respond_to do |format|
      		if @push_notification.save
            format.html { redirect_to push_notifications_path, :notice => 'You have successfully sent a notification' }
        		format.xml  { render :xml => @push_notification, :status => :created, :push_notification => @push_notification }
      		else
        		format.html { render :action => "new" }
        		format.xml  { render :xml => @push_notification.errors, :status => :unprocessable_entity }
      		end
    	end
	end
	def update
    @push_notification = PushNotification.find(params[:id])
      respond_to do |format|
          if @push_notification.update(push_notification_params)
            format.html { redirect_to push_notifications_path, notice: 'Successfully Updated.' }
            format.xml  { render :xml => @push_notification, :status => :created, :push_notification => @push_notification }
          else
            format.html { render :edit }
            format.json { render json: @push_notification.errors, status: :unprocessable_entity }
          end
      end
  end

	def destroy
    	@push_notification = PushNotification.find(params[:id])
    	respond_to do |format|
          if @push_notification.destroy
            format.html { redirect_to push_notifications_path, :notice => 'Successfully Removed.' }
            format.xml  { render :xml => @push_notification, :status => :created, :push_notification => @push_notification }
          end
    	end
  end

	def push_notification_params
		params.require(:push_notification).permit(:app_user_id, :message)
	end
end	