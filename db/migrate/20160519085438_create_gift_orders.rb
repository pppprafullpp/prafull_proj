class CreateGiftOrders < ActiveRecord::Migration
  def change
    create_table :gift_orders do |t|
      t.integer :gift_id
      t.integer :order_id

      t.timestamps null: false
    end
  end
end
