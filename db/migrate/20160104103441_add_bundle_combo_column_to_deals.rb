class AddBundleComboColumnToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :bundle_combo, :string
  end
end
