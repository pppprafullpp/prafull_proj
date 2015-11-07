class RemoveColumnFromDeals < ActiveRecord::Migration
  def change
  	remove_column :deals, :you_save_text
  end
end
