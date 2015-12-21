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
    @app_user_device = @push_notification.app_user.device_flag
    if @app_user_device == "iphone"
      pusher = Grocer.pusher(
        certificate: "#{Rails.root}/public/certificates/dev_certificate.pem",      # required
        passphrase:  "1234",                       # optional
        gateway:     "gateway.push.apple.com",                      # optional; See note below.
        port:        2195,                       # optional
        retries:     3                           # optional
      )
      notification = Grocer::Notification.new(
        device_token:      "#{@push_notification.app_user.gcm_id}",
        alert:             "#{@push_notification.message}",
        badge:             42
        #category:          "a category",         # optional; used for custom notification actions
        #sound:             "siren.aiff",         # optional
        #expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
        #identifier:        1234,                 # optional; must be an integer
        #content_available: true                  # optional; any truthy value will set 'content-available' to 1
      )
      #byebug
      pusher.push(notification)
    elsif @app_user_device == "android"
      gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
      registration_id = ["#{@push_notification.app_user.gcm_id}"]
      gcm.send(registration_id, {data: {message: "#{@push_notification.message}"}})
    end
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
	#def create
	#	@push_notification = PushNotification.new(push_notification_params)   
  #  gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
    #byebug
    #registration_id= ["APA91bHAZB4vPEh8cvuVvMQEefI0y5eue42HldyKHJHvPEY7qP1mkY1yVNzufkz6Qw9PjHzlHvDhya-Iol2IvC28f_oHn4Oq-2xWA5-SDKxk7WR-dUgD0dX1GYM4Mb-5mNpU-huCTiVy"]
    #registration_id = @push_notification.app_user.gcm_id if @push_notification.app_user.gcm_id.present? #@app_users.map{|notice| notice.gcm_registration_id}
  #  registration_id = ["#{@push_notification.app_user.gcm_id}"]
  #  gcm.send(registration_id, {data: {message: "#{@push_notification.message}"}})
  #  	respond_to do |format|
  #    		if @push_notification.save
  #          format.html { redirect_to push_notifications_path, :notice => 'You have successfully sent a notification' }
  #      		format.xml  { render :xml => @push_notification, :status => :created, :push_notification => @push_notification }
  #    		else
  #      		format.html { render :action => "new" }
  #      		format.xml  { render :xml => @push_notification.errors, :status => :unprocessable_entity }
  #    		end
  #  	end
	#end
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