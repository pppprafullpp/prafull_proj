class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.string :name
      t.string :description
      t.float :amount
      t.boolean :is_active, default: false
      t.integer :activation_count_condition, default: 0

      t.timestamps null: false
    end
  end
end
