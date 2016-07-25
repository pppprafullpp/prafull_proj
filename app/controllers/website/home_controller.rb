class Website::HomeController < ApplicationController
  layout 'website_layout'
  include DashboardsHelper

  def index
    session[:zip_code] = 75024 unless session[:zip_code].present?
    session[:user_type] = AppUser::RESIDENCE unless session[:user_type].present?
    if session[:user_id].present? && session[:zip_code].present?
      @best_deal_data = get_dashboard_deals(session[:user_id],nil,nil)
    end
    if session[:zip_code].present? && session[:user_type].present?
      @trending_deal_data = get_dashboard_deals(nil,session[:zip_code],session[:user_type])
    end
  end

  ## we are not using this function in website as this gives mixed deals of all categories
  def deals
    ###############   When User is Logged In and zip code is present   ###############
    if session[:user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
      @dashboard_data = get_dashboard_deals(session[:user_id],nil,nil)
      ###############   When User is not logged in and zip code is present   ###############
    elsif session[:user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
      @dashboard_data = get_dashboard_deals(nil,params[:zip_code],params[:deal_type])
      ###############  Filtering  ###############
    elsif session[:user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].present? && params[:sorting_flag].present?
      @dashboard_data = filtered_deals(nil,params[:category],params[:zip_code],params[:deal_type],params[:sorting_flag])
    elsif session[:user_id].present? && params[:zip_code].present? && params[:deal_type].blank? && params[:category].present? && params[:sorting_flag].present?
      @dashboard_data = filtered_deals(session[:user_id],params[:category],nil,nil,params[:sorting_flag])
    end
    #raise @dashboard_data.inspect
    #if params[:category_id].present? and params[:zip_code].present? and params[:deal_type].present?
    #@dashboard_data = get_category_deals(session[:user_id],params[:category_id],params[:zip_code],params[:deal_type])
    #else
    #@dashboard_data = []
    #end

  end

  def get_deals_from_first_page
    service_category_id=params[:service_category_id]
    deals=get_dashboard_deals(nil,params[:zip_code],params[:deal_type])
    @dashboard_data = get_category_deals(nil,params[:service_category_id],params[:zip_code],params[:deal_type])
    @providers = ServiceProvider.get_provider_by_category(params[:service_category_id])
    @category_name=ServiceCategory.find(params[:service_category_id]).name
  end

  def deal_details
    if session[:user_id].present? and params[:category_id].present? and params[:zip_code].present?
      @dashboard_data = get_category_deals(session[:user_id],params[:category_id],nil,nil,{'sort_by' => params[:sort_by],'provider_ids' => params[:provider_ids]})
    elsif session[:user_id].blank? and params[:category_id].present? and params[:zip_code].present? and params[:deal_type].present?
      @dashboard_data = get_category_deals(nil,params[:category_id],params[:zip_code],params[:deal_type],{'sort_by' => params[:sort_by],'provider_ids' => params[:provider_ids]})
    else
      @dashboard_data = []
    end
    deal_provider_ids =  ServiceProvider.get_deal_wise_provider_ids(@dashboard_data)
    @providers = ServiceProvider.get_provider_by_category(params[:category_id]).where(:id => deal_provider_ids)
    begin
      if session[:user_id].present? and AppUser.find(session[:user_id]).orders.present?
        ordered_deals_id=[]
        order_ids=AppUser.find(session[:user_id]).orders.pluck(:id)
        @deal_ids=[]
        @deal_ids=OrderItem.where(:order_id=>order_ids).pluck(:deal_id)
      end
    rescue
    end
    @category_name = ServiceCategory.find(params[:category_id]).name.titleize
  end

  def more_deal_details
    @deal = Deal.find_by_id(params[:deal_id])
    @category_name = ServiceCategory.find(@deal.service_category_id).name.downcase
    @deal_equipments = eval("@deal.#{@category_name}_deal_attributes.first.#{@category_name}_equipments")
  end

  def compare_deals
    if params[:deal_ids].present? && session[:user_id]
      @app_user = AppUser.find(session[:user_id])
      deal_ids = params[:deal_ids].split(",")
      @deal_first = Deal.find(deal_ids.first)
      @deal_second = Deal.find(deal_ids.last)
      @category = ServiceCategory.find(@deal_first.service_category_id).name.downcase
      @current_deal = @app_user.service_preferences.where(:service_category_name => @category.capitalize).first
      @current_deal_preferences = eval("@current_deal.#{@category}_service_preferences").first rescue nil
      @deal_attributes_first = eval("@deal_first.#{@category}_deal_attributes").first
      @deal_attributes_second = eval("@deal_second.#{@category}_deal_attributes").first
      @deal_equipment_first = eval("@deal_attributes_first.#{@category}_equipments").first
      @deal_equipment_second = eval("@deal_attributes_second.#{@category}_equipments").first
    end
  end

  def set_zipcode_and_usertype
    session[:zip_code] = params[:zip_code]
    session[:user_type] = (params[:user_type] == 'option1') ? AppUser::RESIDENCE : AppUser::BUSINESS
    redirect_to service_deals_path
  end
end
