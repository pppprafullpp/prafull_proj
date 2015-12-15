class ChangeColumnTypeInternetPreference < ActiveRecord::Migration
  def change
  	change_column :internet_service_preferences, :upload_speed, :float
  	change_column :internet_service_preferences, :download_speed, :float
  	change_column :deals, :upload_speed, :float
  	change_column :deals, :download_speed, :float
  	change_column :deals, :data_plan, :float
  	change_column :deals, :data_speed, :float
  	change_column :cellphone_service_preferences, :data_plan, :float
  	change_column :cellphone_service_preferences, :data_speed, :float
  	change_column :bundle_service_preferences, :data_plan, :float
  	change_column :bundle_service_preferences, :data_speed, :float
  	change_column :bundle_service_preferences, :upload_speed, :float
  	change_column :bundle_service_preferences, :download_speed, :float
  	change_column :bundle_service_preferences, :data, :float
  end
end
