namespace :reminder_notification do
  desc "TODO"
  task email_trending_deals: :environment do
    @app_users = AppUser.joins(:notification).where("recieve_trending_deals = ?", true).to_a
    @app_users.each do |app_user|

      DealNotifier.send_trending_deal(app_user).deliver
      #@app_user_device = app_user.device_flag
      #@state = app_user.state
      #@service_preferences = app_user.service_preferences.to_a

      #@service_preferences.each do |sp|
      #  byebug
      #  if sp.service_category_id == 1
      #    @internet_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      #  elsif sp.service_category_id == 2
      #    @telephone_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      #  end  
      #end  
    end  
  end
end  