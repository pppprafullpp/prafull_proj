class CreateInternetServicePreferences < ActiveRecord::Migration
  def change
    create_table :internet_service_preferences do |t|
    	t.belongs_to :service_preference, index: true
    	t.string :upload_speed
      t.string :download_speed
      t.string :data
      t.string :email
      t.string :online_storage
      t.string :wifi_hotspot
      t.timestamps null: false
    end
    add_foreign_key :internet_service_preferences, :service_preferences
  end
end
