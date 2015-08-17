class CreatePushNotifications < ActiveRecord::Migration
  def change
    create_table :push_notifications do |t|
    	t.belongs_to :app_user, index: true
    	t.text :message
      t.timestamps null: false
    end
    add_foreign_key :push_notifications, :app_users
  end
end
