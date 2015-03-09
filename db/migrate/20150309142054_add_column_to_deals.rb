class AddColumnToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :service_provider, :string
  	add_column :deals, :short_description, :text
  	add_column :deals, :price, :integer
  end
end
