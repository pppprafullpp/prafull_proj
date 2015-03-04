class RenameTableAppUserServicePreferences < ActiveRecord::Migration
  def change
  	rename_table :app_users_service_preferences, :service_preferences
  end
end
