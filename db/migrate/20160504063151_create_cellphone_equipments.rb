class CreateCellphoneEquipments < ActiveRecord::Migration
  def change
    create_table :cellphone_equipments do |t|
    	t.integer :cellphone_deal_attribute_id
      t.string  :name
      t.decimal :price, precision: 30, scale: 2
      t.text    :installation
      t.string  :activation
      t.boolean :is_active

      t.timestamps null: false
    end
  end
end
