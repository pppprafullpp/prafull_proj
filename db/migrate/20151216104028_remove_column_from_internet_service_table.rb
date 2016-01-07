class RemoveColumnFromInternetServiceTable < ActiveRecord::Migration
  def change
  	remove_column :internet_service_preferences, :email
  	remove_column :internet_service_preferences, :data
  end
end
