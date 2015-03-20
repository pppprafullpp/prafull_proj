class AddAvatarColumnToAppUsers < ActiveRecord::Migration
  def change
  	add_attachment :app_users, :avatar
  end
end
