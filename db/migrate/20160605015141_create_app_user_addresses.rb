class CreateAppUserAddresses < ActiveRecord::Migration
  def change
    create_table :app_user_addresses do |t|
      t.integer :app_user_id
      t.string :name
      t.string :dba
      t.string :zip
      t.string :address
      t.integer :address_type
      t.string :contact_number
      t.string :federal_number
      t.string :db_number
      t.timestamps null: false
    end
  end
end