class RenameColumnInDeals < ActiveRecord::Migration
  def change
  	rename_column :deals, :company, :url
  end
end
