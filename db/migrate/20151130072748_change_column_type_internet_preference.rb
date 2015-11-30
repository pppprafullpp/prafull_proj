class ChangeColumnTypeInternetPreference < ActiveRecord::Migration
  def change
  	change_column :internet_service_preferences, :upload_speed,  :integer, :default => 0
  	change_column :internet_service_preferences, :download_speed,  :integer, :default => 0
  end
end
