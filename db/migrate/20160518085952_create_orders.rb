class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :deal_id
      t.integer :app_user_id
      t.boolean :status
      t.float :effective_price
      t.float :deal_price
      t.datetime :activation_start_date

      t.timestamps null: false
    end
  end
end
