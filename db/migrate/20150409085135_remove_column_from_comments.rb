class RemoveColumnFromComments < ActiveRecord::Migration
  def change
  	remove_column :comments, :app_user_name
  end
end
