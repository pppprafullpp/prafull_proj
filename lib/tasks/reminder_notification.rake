namespace :reminder_notification do
  desc "TODO"
  task send_notification: :environment do
    gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
    @app_users = AppUser.joins(:notification).where("recieve_notification = ?", true).to_a
    @app_users.each do |app_user|
      registration_id = ["#{app_user.gcm_id}"]
      @app_user_notification_day = app_user.notification.day
      @set_preferences = app_user.service_preferences
      @set_preferences.each do |sp|
        @service_category = sp.service_category.name
        @app_user_contract_date = sp.contract_date
        if @app_user_contract_date.present? && @app_user_notification_day.present?
          @remaining_days = (@app_user_contract_date.to_datetime - DateTime.now).to_i
          if @remaining_days < @app_user_notification_day
            gcm.send(registration_id, {data: {message: "#{@service_category} : Reminder notification"}})
            puts "#{app_user.id} Notification sent"
          end
        end
      end  
    end  
  end

  #desc "TODO"
  #task test_task: :environment do
  #	gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
  #	registration_id = ["APA91bEUvak1n5xH22h3l15BiqgyCHnHMehER7e1IyJ4R6sgkK-3ZKSfa7E9SRGVGWf6-dWbLKxOhXlHgWpeDGCGykbZ4T5SrLcsTI4AEgWDGbJwvDn0siTsuegi0nugkjpmfMF64ZBs"]
  #	gcm.send(registration_id, {data: {message: "Rake Task test notification"}})
  #	puts "OK"
  #end

end
