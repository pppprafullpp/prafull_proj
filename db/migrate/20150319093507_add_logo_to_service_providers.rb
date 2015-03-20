class AddLogoToServiceProviders < ActiveRecord::Migration
  def change
  	add_attachment :service_providers, :logo
  end
end
