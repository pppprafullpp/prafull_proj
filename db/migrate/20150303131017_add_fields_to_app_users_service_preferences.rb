class AddFieldsToAppUsersServicePreferences < ActiveRecord::Migration
  def change
    add_column :app_users_service_preferences, :app_user_id, :integer
  end
end
