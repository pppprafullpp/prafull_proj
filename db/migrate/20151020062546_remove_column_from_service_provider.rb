class RemoveColumnFromServiceProvider < ActiveRecord::Migration
  def change
  	remove_column :service_providers, :service_category_name
  end
end
