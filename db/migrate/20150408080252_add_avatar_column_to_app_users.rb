class AddAvatarColumnToAppUsers < ActiveRecord::Migration
  def change
    add_column :app_users, :avatar, :string
  end
end
