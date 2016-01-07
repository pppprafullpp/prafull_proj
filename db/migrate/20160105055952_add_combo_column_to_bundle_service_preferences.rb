class AddComboColumnToBundleServicePreferences < ActiveRecord::Migration
  def change
  	add_column :bundle_service_preferences, :bundle_combo, :string
  end
end
