class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enabled, :boolean
    add_column :users, :failed_count, :integer
    add_column :users, :password_updated_at, :date
  end
end
