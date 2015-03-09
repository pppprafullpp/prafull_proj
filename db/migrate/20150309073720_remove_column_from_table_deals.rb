class RemoveColumnFromTableDeals < ActiveRecord::Migration
  def change
  	remove_column :deals, :zip
  	remove_column :deals, :state
  end
end

