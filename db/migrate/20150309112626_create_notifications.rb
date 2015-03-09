class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :app_user_id
      t.boolean :notification
      t.integer :day
      t.timestamps null: false
    end
  end
end
