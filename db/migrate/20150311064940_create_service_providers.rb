class CreateServiceProviders < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.string  :name
      t.belongs_to :service_category, index:true
      t.string  :service_category_name
      t.string  :address
      t.string  :state
      t.string  :city
      t.string  :zip
      t.string  :email
      t.string  :telephone
      t.boolean :is_preferred, default: false
      t.boolean :is_active, default: true
      t.timestamps null: false
    end
  end
end
