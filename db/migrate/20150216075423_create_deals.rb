class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.belongs_to :service_category, index: true
      t.belongs_to :service_provider, index: true
      t.string :service_category_name
      t.string :service_provider_name
      t.string :title
      t.string :state
      t.string :city
      t.string :zip
      t.text :short_description
      t.text :detail_description
      t.float :price
      t.string :url
      t.text :you_save_text
      t.datetime :start_date
      t.datetime :end_date
      
      t.timestamps null: false
    end
  end
end
