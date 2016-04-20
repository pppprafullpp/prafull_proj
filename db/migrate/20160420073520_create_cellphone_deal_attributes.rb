class CreateCellphoneDealAttributes < ActiveRecord::Migration
  def change
    create_table :cellphone_deal_attributes do |t|
      t.integer  :deal_id
      t.string   :domestic_call_minutes
      t.string	 :domestic_text
      t.string   :international_call_minutes
      t.string   :international_text
      t.float	   :data_plan
      t.string	 :data_speed
      t.text     :equipment
      t.text     :installation
      t.string   :activation
      t.timestamps null: false
    end
    add_index :cellphone_deal_attributes, :deal_id
  end
end
