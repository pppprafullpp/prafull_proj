class CreateServicePreferences < ActiveRecord::Migration
  def change
    create_table :service_preferences do |t|
      t.belongs_to :app_user, index: true
      t.belongs_to :service_category, index: true
      t.belongs_to :service_provider, index: true
      t.string :service_category_name
      t.string :service_provider_name
      t.datetime :contract_date
      t.boolean :is_contract
      t.float :contract_fee	

      t.timestamps null: false
    end
  end
end
