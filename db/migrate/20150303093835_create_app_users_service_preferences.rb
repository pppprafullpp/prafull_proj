class CreateAppUsersServicePreferences < ActiveRecord::Migration
  def change
    create_table :app_users_service_preferences do |t|
      t.string :service_name
      t.string :service_provider
      t.datetime :contract_date
      t.boolean :is_contract
      t.integer :contract_fee	

      t.timestamps null: false
    end
  end
end
