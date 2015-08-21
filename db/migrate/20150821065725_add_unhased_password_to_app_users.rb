class AddUnhasedPasswordToAppUsers < ActiveRecord::Migration
  def change
    add_column :app_users, :unhashed_password, :string
  end
end
