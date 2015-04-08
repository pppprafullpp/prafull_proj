class AddLogoColumnToServiceProviders < ActiveRecord::Migration
  def change
    add_column :service_providers, :logo, :string
  end
end
