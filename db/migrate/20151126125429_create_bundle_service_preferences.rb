class CreateBundleServicePreferences < ActiveRecord::Migration
  def change
    create_table :bundle_service_preferences do |t|
      t.belongs_to :service_preference, index: true
      t.string :upload_speed
      t.string :download_speed
      t.string :data
      t.integer :free_channels
      t.integer :premium_channels
      t.integer :call_minutes
      t.integer :text_messages
      t.integer :data_plan
      t.integer :data_speed
      t.boolean :talk_unlimited, default: false
      t.boolean :text_unlimited, default: false
      t.timestamps null: false
    end
    add_foreign_key :bundle_service_preferences, :service_preferences
  end
end