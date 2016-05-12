class CreateInternetEquipments < ActiveRecord::Migration
  def change
    create_table :internet_equipments do |t|
    	  t.integer :internet_deal_attribute_id
	      t.string  :name
	      t.string  :make
	      t.decimal :price, precision: 30, scale: 2,default: "0"
	      t.text    :installation
	      t.string  :activation
	      t.string  :offer
	      t.boolean :is_active
	      t.timestamps null: false
    end
  end
end
