class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.belongs_to :service_category, index: true
      t.belongs_to :service_provider, index: true
      t.string :title
      t.text :short_description
      t.text :detail_description
      t.float :price
      t.string :url
      t.string :image
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :is_nationwide, default: false
      t.boolean :is_business, default: false
      t.boolean :is_active, default: true
      
      t.timestamps null: false
    end
    add_foreign_key :deals, :service_categories
  end
end
