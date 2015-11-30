class RemoveColumnFromInternetServicePreferences < ActiveRecord::Migration
  def change
  	remove_column :internet_service_preferences, :upload_speed
  	remove_column :internet_service_preferences, :download_speed
  end
end
