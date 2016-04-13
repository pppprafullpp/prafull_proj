class CreateAdditionalOffers < ActiveRecord::Migration
  def change
    create_table :additional_offers do |t|
      t.integer :deal_id
      t.string :title
      t.text :description
      t.float :price_value
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :is_active, default: true
      t.timestamps null: false
    end
    add_index :additional_offers, :deal_id
  end
end
