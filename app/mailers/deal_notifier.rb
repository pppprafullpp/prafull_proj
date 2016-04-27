class DealNotifier < ApplicationMailer
	def send_trending_deal(app_user)
		recipient = app_user.email
    @app_user = app_user
    if @app_user.user_type=="residence"
      @is_business=false
    else
      @is_business=true
    end
		@service_preferences = app_user.service_preferences.to_a
    @service_preferences.each do |sp|
      if sp.service_category_id == 1
        @internet_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @internet_t_deal.present?
      		@internet_deal = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.*").where("deals.id = ? AND deals.is_active = ? AND deals.is_business = ?", @internet_t_deal.deal_id,true,@is_business).first
      	end	
      elsif sp.service_category_id == 2
        @telephone_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @telephone_t_deal.present?
      		@telephone_deal = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.id = ? AND deals.is_active = ? AND deals.is_business = ?", @telephone_t_deal.deal_id,true,@is_business).first
      	end
      elsif sp.service_category_id == 3
      	@cable_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cable_t_deal.present?
      		@cable_deal = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.*").where("deals.id = ? AND deals.is_active = ? AND deals.is_business = ?", @cable_t_deal.deal_id,true,@is_business).first
      	end
      elsif sp.service_category_id == 4
      	@cell_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cell_t_deal.present?
      		@cellphone_deal = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.id = ? AND deals.is_active = ? AND deals.is_business = ?", @cell_t_deal.deal_id,true,@is_business).first
      	end
      elsif sp.service_category_id == 5
        @bundle_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
        if @bundle_t_deal.present?
          @bundle_deal = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.*").where("deals.id = ? AND deals.is_active = ? AND deals.is_business = ?", @bundle_t_deal.deal_id,true,@is_business).first
        end
      end  
    end 
    mail(to: recipient, subject: "Switch to the trending deals in your area and save $100s") rescue nil
	end	

  def send_best_deal(app_user,best_deal)
    recipient = app_user.email
    @app_user = app_user
    @best_deal=best_deal
    mail(to: recipient, subject: "Best Deals for you") rescue nil
  end

  def send_best_deal_contract(app_user,service_preference)
    recipient = app_user.email
    @app_user = app_user
    if @app_user.user_type=="residence"
      @is_business=false
    else
      @is_business=true
    end
    @service_preference=service_preference
    @current_plan_price = service_preference.price
    if service_preference.service_category_id == 1
      @current_d_speed = service_preference.internet_service_preference.download_speed
      @equal_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND internet_deal_attributes.download = ?", true,@is_business, service_preference.service_category_id, @current_d_speed).order("price ASC")
      @greater_deals = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND internet_deal_attributes.download > ?", true,@is_business, service_preference.service_category_id, @current_d_speed).order("price ASC").limit(2)
    elsif service_preference.service_category_id == 2 
      if service_preference.telephone_service_preference.domestic_call_unlimited == true
        @equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes = 'Unlimited' ", true,@is_business, service_preference.service_category_id).order("price ASC")
        @greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes = 'Unlimited' AND deals.price > ?", true,@is_business, service_preference.service_category_id, @current_plan_price).order("price ASC").limit(2)
      else
        @current_c_minutes = service_preference.telephone_service_preference.domestic_call_minutes
        @equal_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes = ?", true,@is_business, service_preference.service_category_id, @current_c_minutes).order("price ASC")
        @greater_deals = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND telephone_deal_attributes.domestic_call_minutes > ?", true,@is_business, service_preference.service_category_id, @current_c_minutes).order("price ASC").limit(2)
      end
    elsif service_preference.service_category_id == 3
      @current_f_channels = service_preference.cable_service_preference.free_channels
      @equal_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cable_deal_attributes.free_channels = ?", true,@is_business, service_preference.service_category_id, @current_f_channels).order("price ASC")
      @greater_deals = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cable_deal_attributes.free_channels > ?", true,@is_business, service_preference.service_category_id, @current_f_channels).order("price ASC").limit(2)
    elsif service_preference.service_category_id == 4
      if service_preference.cellphone_service_preference.domestic_call_unlimited == true
        @equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cellphone_deal_attributes.domestic_call_minutes = 'Unlimited' ", true,@is_business, service_preference.service_category_id).order("price ASC")
        @greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cellphone_deal_attributes.domestic_call_minutes = 'Unlimited' AND deals.price > ?", true,@is_business, service_preference.service_category_id, @current_plan_price).order("price ASC").limit(2)
      else
        @current_c_minutes = service_preference.cellphone_service_preference.domestic_call_minutes
        @equal_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cellphone_deal_attributes.domestic_call_minutes = ?", true,@is_business, service_preference.service_category_id, @current_c_minutes).order("price ASC")
        @greater_deals = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND cellphone_deal_attributes.domestic_call_minutes > ?", true,@is_business, service_preference.service_category_id, @current_c_minutes).order("price ASC").limit(2)
      end 
    elsif service_preference.service_category_id == 5
      @bundle_combo = service_preference.bundle_service_preference.bundle_combo
      @equal_deals = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.*").where("deals.is_active = ? AND deals.is_business = ? AND deals.service_category_id = ? AND bundle_deal_attributes.bundle_combo = ?", true,@is_business, service_preference.service_category_id,@bundle_combo).order("price ASC").limit(5)  
    end 
    if @equal_deals.present? && @greater_deals.present?
      @merged_deals = (@equal_deals + @greater_deals).sort_by(&:price)
    elsif @equal_deals.present? && @greater_deals.blank?
      @merged_deals = (@equal_deals).sort_by(&:price)
    elsif @equal_deals.blank? && @greater_deals.present?
      @merged_deals = (@greater_deals).sort_by(&:price)
    end
    if @merged_deals.present?
      @best_deal = @merged_deals.first
    end
    if @best_deal.present?
      mail(to: recipient, subject: "Your #{service_preference.service_category.name} service is expiring on #{service_preference.end_date.to_date}") rescue nil
    end
  end
end
