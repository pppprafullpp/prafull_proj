class DeleteColumnFromBundleServicePreferences < ActiveRecord::Migration
  def change
  	remove_column :bundle_service_preferences, :upload_speed
  	remove_column :bundle_service_preferences, :download_speed
  	remove_column :bundle_service_preferences, :data
  end
end
