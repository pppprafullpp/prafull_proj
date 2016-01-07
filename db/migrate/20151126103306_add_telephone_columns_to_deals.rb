class AddTelephoneColumnsToDeals < ActiveRecord::Migration
  def change
  	add_column :deals, :call_minutes, :integer
    add_column :deals, :text_messages, :integer
    add_column :deals, :talk_unlimited, :boolean
    add_column :deals, :text_unlimited, :boolean
  end
end
