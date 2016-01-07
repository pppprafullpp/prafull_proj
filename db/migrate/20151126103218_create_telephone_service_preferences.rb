class CreateTelephoneServicePreferences < ActiveRecord::Migration
  def change
    create_table :telephone_service_preferences do |t|
      t.belongs_to :service_preference, index: true
      t.integer :call_minutes
      t.integer :text_messages
      t.boolean :talk_unlimited, default: false
      t.boolean :text_unlimited, default: false
      t.timestamps null: false
    end
    add_foreign_key :telephone_service_preferences, :service_preferences
  end
end
