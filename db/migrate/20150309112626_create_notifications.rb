class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
	  t.belongs_to :app_user, index: true
      t.boolean :recieve_notification
      t.integer :day
      t.timestamps null: false
    end
  end
end
