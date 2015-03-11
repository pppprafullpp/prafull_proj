class CreateServiceProviders < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.string  :name
      t.belongs_to :service_category, index:true
      t.string  :state
      t.string  :city
      t.string  :zip
      t.timestamps null: false
    end
  end
end
