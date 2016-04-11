class CreateTelephoneDealAttributes < ActiveRecord::Migration
  def change
    create_table :telephone_deal_attributes do |t|
      t.belongs_to :deal, index: true
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
    add_foreign_key :telephone_deal_attributes, :deals
  end
end
