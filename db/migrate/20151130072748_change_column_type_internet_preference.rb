class ChangeColumnTypeInternetPreference < ActiveRecord::Migration
  def change
  	change_column :internet_service_preferences, :upload_speed,  :integer
  	change_column :internet_service_preferences, :download_speed,  :integer
  end
end
