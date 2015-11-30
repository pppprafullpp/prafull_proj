class ChangeColumnTypeDeals < ActiveRecord::Migration
  def change
  	change_column :deals, :upload_speed,  :integer, :default => 0
  	change_column :deals, :download_speed,  :integer, :default => 0
  end
end
