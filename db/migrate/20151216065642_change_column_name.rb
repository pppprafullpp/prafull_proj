class ChangeColumnName < ActiveRecord::Migration
  def change
  	rename_column :bundle_service_preferences, :call_minutes, :domestic_call_minutes
  	rename_column :bundle_service_preferences, :text_messages, :international_call_minutes
  	rename_column :bundle_service_preferences, :talk_unlimited, :domestic_call_unlimited
  	rename_column :bundle_service_preferences, :text_unlimited, :international_call_unlimited
  	rename_column :cellphone_service_preferences, :call_minutes, :domestic_call_minutes
  	rename_column :cellphone_service_preferences, :text_messages, :international_call_minutes
  	rename_column :cellphone_service_preferences, :talk_unlimited, :domestic_call_unlimited
  	rename_column :cellphone_service_preferences, :text_unlimited, :international_call_unlimited
  	rename_column :deals, :call_minutes, :domestic_call_minutes
  	rename_column :deals, :text_messages, :international_call_minutes
  	rename_column :deals, :talk_unlimited, :domestic_call_unlimited
  	rename_column :deals, :text_unlimited, :international_call_unlimited
  	rename_column :telephone_service_preferences, :call_minutes, :domestic_call_minutes
  	rename_column :telephone_service_preferences, :text_messages, :international_call_minutes
  	rename_column :telephone_service_preferences, :talk_unlimited, :domestic_call_unlimited
  	rename_column :telephone_service_preferences, :text_unlimited, :international_call_unlimited
  end
end
