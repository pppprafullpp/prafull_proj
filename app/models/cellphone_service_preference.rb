class CellphoneServicePreference < ActiveRecord::Base
  belongs_to :service_preference
  def as_json(opts={})
    json = super(opts)
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  def self.cellphone_best_deal(service_preference,select_data,deal_validation_conditions,restricted_deals)
    best_deals = nil
    existing_domestic_call_unlimited = service_preference.cellphone_service_preference.domestic_call_unlimited
    existing_domestic_call_minutes = (existing_domestic_call_unlimited == true) ? 0 : service_preference.cellphone_service_preference.domestic_call_minutes
    existing_data_plan = service_preference.cellphone_service_preference.data_plan

    best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.data_plan > ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price <= ? AND deals.id not in (?)", existing_data_plan,service_preference.price,restricted_deals).order("price ASC")
    if best_deals.blank?
      best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.data_plan > ? AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes > ? AND deals.price <= ? AND deals.id not in (?)", existing_data_plan,existing_domestic_call_minutes,service_preference.price,restricted_deals).order("price ASC")
    end
    if best_deals.blank?
      best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.data_plan = ? AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price <= ? AND deals.id not in (?)", existing_data_plan,service_preference.price,restricted_deals).order("price ASC")
    end
    if best_deals.blank?
      best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.data_plan = ? AND cellphone_deal_attributes.domestic_call_minutes!='Unlimited' AND cellphone_deal_attributes.domestic_call_minutes > ? AND deals.price <= ? AND deals.id not in (?)", existing_data_plan,existing_domestic_call_minutes,service_preference.price,restricted_deals).order("price ASC")
    end
    if best_deals.blank?
      best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.data_plan > ? AND deals.price <= ? AND deals.id not in (?)", existing_data_plan,service_preference.price,restricted_deals).order("price ASC")
    end
    if best_deals.blank?
      best_deals = Deal.joins(:cellphone_deal_attributes).select(select_data).where(deal_validation_conditions+" AND cellphone_deal_attributes.domestic_call_minutes='Unlimited' AND deals.price < ? AND deals.id not in (?)",service_preference.price,restricted_deals).order("price ASC")
    end
    best_deals
  end

end
