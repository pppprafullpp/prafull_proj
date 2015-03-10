class AddAddressColumnToAppUsers < ActiveRecord::Migration
  def change
  	add_column :app_users, :address, :string
  end
end
