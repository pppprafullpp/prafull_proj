class AddCellphoneColumnsToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :data_plan, :integer
    add_column :deals, :data_speed, :integer
  end
end
