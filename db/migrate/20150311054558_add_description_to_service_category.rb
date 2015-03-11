class AddDescriptionToServiceCategory < ActiveRecord::Migration
  def change
  	add_column :service_categories, :description, :text
  end
end
