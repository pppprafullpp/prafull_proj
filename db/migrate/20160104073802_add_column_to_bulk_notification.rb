class AddColumnToBulkNotification < ActiveRecord::Migration
  def change
  	add_column :bulk_notifications, :category, :string
  end
end
