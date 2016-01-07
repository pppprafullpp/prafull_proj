class AddColumnToNotifications < ActiveRecord::Migration
  def change
  	add_column :notifications, :recieve_trending_deals, :boolean, default: true
  end
end
