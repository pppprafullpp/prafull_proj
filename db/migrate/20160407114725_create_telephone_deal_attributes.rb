class CreateTelephoneDealAttributes < ActiveRecord::Migration
  def change
    create_table :telephone_deal_attributes do |t|
      t.integer   :deal_id
      t.integer  :domestic_call_minutes
      t.integer	 :domestic_receive_minutes
      t.integer	 :domestic_additional_minutes
      t.integer  :international_landline_minutes
      t.integer	 :international_mobile_minutes
      t.integer  :international_additional_minutes
      t.text	   :countries
      t.text	   :features
      t.text     :equipment
      t.text     :installation
      t.string   :activation
      t.timestamps null:false
    end
    add_index :telephone_deal_attributes, :deal_id
  end
end
