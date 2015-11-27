class AddCableColumnsToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :free_channels, :integer
    add_column :deals, :premium_channels, :integer
  end
end
