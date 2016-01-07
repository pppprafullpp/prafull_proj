class AddColumnToAppUsers < ActiveRecord::Migration
  def change
  	add_column :app_users, :device_flag, :string
  end
end
