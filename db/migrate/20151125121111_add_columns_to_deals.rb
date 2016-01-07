class AddColumnsToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :upload_speed, :string
    add_column :deals, :download_speed, :string
  end
end
