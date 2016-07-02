class AlterDealsAddEffectivePrice < ActiveRecord::Migration
  def change
    add_column :deals, :effective_price, :decimal
  end
end
