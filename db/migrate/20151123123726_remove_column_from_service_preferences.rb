class RemoveColumnFromServicePreferences < ActiveRecord::Migration
  def change
  	remove_column :service_preferences, :upload_speed
  	remove_column :service_preferences, :download_speed
  	remove_column :service_preferences, :contract_fee
  	remove_column :service_preferences, :contract_date
  end
end
