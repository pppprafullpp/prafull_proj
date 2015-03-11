class AddAddressColumnToServiceProviders < ActiveRecord::Migration
  def change
  	add_column :service_providers, :address, :string
  end
end
