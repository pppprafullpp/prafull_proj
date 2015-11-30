class AddSpeedColumnToInternetServicePreferences < ActiveRecord::Migration
  def change
  	add_column :internet_service_preferences, :upload_speed, :integer
    add_column :internet_service_preferences, :download_speed, :integer
  end
end
