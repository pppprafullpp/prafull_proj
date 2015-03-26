class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.belongs_to :app_user, index: true
      t.belongs_to :deal, index: true
      t.float :rating_point
      t.timestamps null: false
    end
    add_foreign_key :ratings, :app_users
    add_foreign_key :ratings, :deals
  end
end
