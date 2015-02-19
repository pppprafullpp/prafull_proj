class CreateServiceDeals < ActiveRecord::Migration
  def change
    create_table :service_deals do |t|
      t.string :category
      t.string :company
      t.string :state
      t.integer :zip

      t.timestamps null: false
    end
  end
end
