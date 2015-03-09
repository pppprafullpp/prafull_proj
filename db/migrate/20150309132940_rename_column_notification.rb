class RenameColumnNotification < ActiveRecord::Migration
  def change
  	rename_column :notifications, :notification, :service_notification
  end
end
