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
    #raise @push_notification.inspect 
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