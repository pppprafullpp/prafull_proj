class AddColumnToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :upload_speed, :integer
    add_column :deals, :download_speed, :integer
  end
end
