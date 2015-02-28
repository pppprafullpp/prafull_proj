class AddFirstNameToAppUsers < ActiveRecord::Migration
  def change
    add_column :app_users, :first_name, :string
    add_column :app_users, :last_name, :string
    add_column :app_users, :state, :string
    add_column :app_users, :city, :string
    add_column :app_users, :zip, :integer
  end
end
