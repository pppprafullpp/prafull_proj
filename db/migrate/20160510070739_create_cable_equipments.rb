class CreateCableEquipments < ActiveRecord::Migration
  def change
    create_table :cable_equipments do |t|
    	t.integer :cable_deal_attribute_id
	      t.string  :name
	      t.string  :make
	      t.decimal :price, precision: 30, scale: 2
	      t.text    :installation
	      t.string  :activation
	      t.string  :offer
	      t.boolean :is_active

      t.timestamps null: false
    end
  end
end