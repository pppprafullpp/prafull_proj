class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.belongs_to :app_user, index: true
      t.belongs_to :deal, index: true
      t.string :app_user_name,
      t.boolean :status, default: true
      t.text :comment_text
      t.timestamps null: false
    end
    add_foreign_key :comments, :app_users
    add_foreign_key :comments, :deals
  end
end
