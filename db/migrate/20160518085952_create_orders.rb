class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :deal_id
      t.integer :app_user_id
      t.string :status
      t.float :deal_price
      t.float :effective_price
      t.datetime :activation_date

      t.timestamps null: false
    end
  end
end
