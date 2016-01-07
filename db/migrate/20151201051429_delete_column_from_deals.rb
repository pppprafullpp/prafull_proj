class DeleteColumnFromDeals < ActiveRecord::Migration
  def change
  	remove_column :deals, :upload_speed
  	remove_column :deals, :download_speed
  end
end
