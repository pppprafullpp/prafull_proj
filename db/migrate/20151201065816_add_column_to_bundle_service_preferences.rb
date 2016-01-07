class AddColumnToBundleServicePreferences < ActiveRecord::Migration
  def change
  	add_column :bundle_service_preferences, :upload_speed, :integer
  	add_column :bundle_service_preferences, :download_speed, :integer
  	add_column :bundle_service_preferences, :data, :integer
  end
end
