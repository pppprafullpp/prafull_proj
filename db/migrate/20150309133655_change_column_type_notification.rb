class ChangeColumnTypeNotification < ActiveRecord::Migration
  def change
  	change_column :notifications, :service_notification, :string
  end
end
