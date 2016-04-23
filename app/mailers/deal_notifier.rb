class DealNotifier < ApplicationMailer
	def send_trending_deal(app_user)
		recipient = app_user.email
		@service_preferences = app_user.service_preferences.to_a
    @service_preferences.each do |sp|
      if sp.service_category_id == 1
        @internet_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @internet_t_deal.present?
      		@internet_deal = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.*").where("deals.id = ?", @internet_t_deal.deal_id).take
      		@i_price = @internet_deal.price
      		@i_title = @internet_deal.title
      		@i_provider = @internet_deal.service_provider_name
      		@d_speed = @internet_deal.download
      	end	
      elsif sp.service_category_id == 2
        @telephone_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @telephone_t_deal.present?
      		@telephone_deal = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.id = ?", @telephone_t_deal.deal_id).take
      		@t_title = @telephone_deal.title
      		@t_provider = @telephone_deal.service_provider_name
      		@t_price = @telephone_deal.price
      		@d_call_mins =  @telephone_deal.domestic_call_minutes 
      		@i_call_mins = @telephone_deal.international_call_minutes  
      	end
      elsif sp.service_category_id == 3
      	@cable_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cable_t_deal.present?
      		@cable_deal = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.*").where("deals.id = ?", @cable_t_deal.deal_id).take
      		@c_title = @cable_deal.title
      		@c_provider = @cable_deal.service_provider_name
      		@c_price = @cable_deal.price
      		@f_channels = @cable_deal.free_channels
      		@p_channels = @cable_deal.premium_channels
      	end
      elsif sp.service_category_id == 4
      	@cell_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cell_t_deal.present?
      		@cellphone_deal = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.id = ?", @cell_t_deal.deal_id).take
      		@cell_title = @cellphone_deal.title
      		@cell_provider = @cellphone_deal.service_provider_name
      		@data_plan = @cellphone_deal.data_plan
      		@data_speed = @cellphone_deal.data_speed
      		@cell_price = @cellphone_deal.price
      		@d_call_mins =  @cellphone_deal.domestic_call_minutes 
      		@i_call_mins = @cellphone_deal.international_call_minutes  
      	end
      end  
    end 
    mail(to: recipient, subject: "Trending Deals for you.") rescue nil
	end	
end
