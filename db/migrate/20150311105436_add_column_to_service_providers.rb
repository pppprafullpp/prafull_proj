class AddColumnToServiceProviders < ActiveRecord::Migration
  def change
  	add_column :service_providers, :service_category_name, :string
  end
end
