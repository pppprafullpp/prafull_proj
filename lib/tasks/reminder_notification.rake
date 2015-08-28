namespace :reminder_notification do
  desc "TODO"
  task send_notification: :environment do
  end

  desc "TODO"
  task test_task: :environment do
  	gcm = GCM.new("AIzaSyASkbVZHnrSGtqjruBalX0o0rQRA1dYU7w")
  	registration_id = ["APA91bEUvak1n5xH22h3l15BiqgyCHnHMehER7e1IyJ4R6sgkK-3ZKSfa7E9SRGVGWf6-dWbLKxOhXlHgWpeDGCGykbZ4T5SrLcsTI4AEgWDGbJwvDn0siTsuegi0nugkjpmfMF64ZBs"]
  	gcm.send(registration_id, {data: {message: "Rake Task test notification"}})
  	puts "OK"
  end

end
