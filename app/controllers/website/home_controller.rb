class Website::HomeController < ApplicationController
  layout 'website_layout'
  include DashboardsHelper

  def index

  end

  def deals
    ###############   When User is Logged In and zip code is present   ###############
    #if session[:user_id].present? && params[:zip_code].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
    #@dashboard_data = get_dashboard_deals(session[:user_id],nil,nil)
    ###############   When User is not logged in and zip code is present   ###############
    #elsif session[:user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].blank? && params[:sort_by_d_speed].blank?
    #@dashboard_data = get_dashboard_deals(nil,params[:zip_code],params[:deal_type])
    ###############  Filtering  ###############
    #elsif session[:user_id].blank? && params[:zip_code].present? && params[:deal_type].present? && params[:category].present? && params[:sorting_flag].present?
    #@dashboard_data = filtered_deals(nil,params[:category],params[:zip_code],params[:deal_type],params[:sorting_flag])
    #elsif session[:user_id].present? && params[:zip_code].present? && params[:deal_type].blank? && params[:category].present? && params[:sorting_flag].present?
    #@dashboard_data = filtered_deals(session[:user_id],params[:category],nil,nil,params[:sorting_flag])
    #end
    if params[:category_id].present? and params[:zip_code].present? and params[:deal_type].present?
      @dashboard_data = get_category_deals(session[:user_id],params[:category_id],params[:zip_code],params[:deal_type])
    else
      @dashboard_data = []
    end
  end

end