class AddColumnToServicePreferences < ActiveRecord::Migration
  def change
  	add_column :service_preferences, :start_date, :datetime
  	add_column :service_preferences, :end_date, :datetime
  	add_column :service_preferences, :upload_speed, :string
  	add_column :service_preferences, :download_speed, :string
  	add_column :service_preferences, :price, :float
  end
end
