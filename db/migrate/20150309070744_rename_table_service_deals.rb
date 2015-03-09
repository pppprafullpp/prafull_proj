class RenameTableServiceDeals < ActiveRecord::Migration
  def change
  	rename_table :service_deals, :deals
  end
end
