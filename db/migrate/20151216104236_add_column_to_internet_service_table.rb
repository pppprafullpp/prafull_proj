class AddColumnToInternetServiceTable < ActiveRecord::Migration
  def change
  	add_column :internet_service_preferences, :email, :integer
    add_column :internet_service_preferences, :data, :float
  end
end
