class DealNotifier < ApplicationMailer
  include DashboardsHelper

	def send_trending_deal(app_user)
		recipient = app_user.email
    @app_user = app_user
    if @app_user.user_type=="residence"
      @deal_type="residence"
    elsif @app_user.user_type=="business"
      @deal_type="business"
    end
    @service_preferences = app_user.service_preferences.to_a
    @service_preferences.each do |sp|
      deal_validation_conditions="deals.is_active=true AND deals.deal_type='"+@deal_type+"'"

      if sp.service_category_id == 1
        @internet_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @internet_t_deal.present?
      		@internet_deal = Deal.joins(:internet_deal_attributes).select("deals.*,internet_deal_attributes.*").where("deals.id = ? AND "+deal_validation_conditions, @internet_t_deal.deal_id).first
      	end	
      elsif sp.service_category_id == 2
        @telephone_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @telephone_t_deal.present?
      		@telephone_deal = Deal.joins(:telephone_deal_attributes).select("deals.*,telephone_deal_attributes.*").where("deals.id = ? AND "+deal_validation_conditions, @telephone_t_deal.deal_id).first
      	end
      elsif sp.service_category_id == 3
      	@cable_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cable_t_deal.present?
      		@cable_deal = Deal.joins(:cable_deal_attributes).select("deals.*,cable_deal_attributes.*").where("deals.id = ? AND "+deal_validation_conditions, @cable_t_deal.deal_id).first
      	end
      elsif sp.service_category_id == 4
      	@cell_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
      	if @cell_t_deal.present?
      		@cellphone_deal = Deal.joins(:cellphone_deal_attributes).select("deals.*,cellphone_deal_attributes.*").where("deals.id = ? AND "+deal_validation_conditions, @cell_t_deal.deal_id).first
      	end
      elsif sp.service_category_id == 5
        @bundle_t_deal = TrendingDeal.where("category_id = ?", sp.service_category_id).order("subscription_count DESC").first
        if @bundle_t_deal.present?
          @bundle_deal = Deal.joins(:bundle_deal_attributes).select("deals.*,bundle_deal_attributes.*").where("deals.id = ? AND "+deal_validation_conditions, @bundle_t_deal.deal_id).first
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
    @deal_type=@app_user.user_type

    @service_preference=service_preference
    
    @best_deal=category_best_deal(@deal_type,@service_preference,@app_user.zip,1)

    if @best_deal.present?
      mail(to: recipient, subject: "Your #{service_preference.service_category.name} service is expiring on #{service_preference.end_date.to_date}") rescue nil
    end
  end
end
