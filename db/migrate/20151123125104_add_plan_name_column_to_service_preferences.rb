class AddPlanNameColumnToServicePreferences < ActiveRecord::Migration
  def change
  	add_column :service_preferences, :plan_name, :string
  end
end
