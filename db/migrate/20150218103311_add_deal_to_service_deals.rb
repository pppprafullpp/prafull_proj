class AddDealToServiceDeals < ActiveRecord::Migration
  def change
    add_column :service_deals, :deal, :text
  end
end
