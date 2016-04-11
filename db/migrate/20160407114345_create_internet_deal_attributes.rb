class CreateInternetDealAttributes < ActiveRecord::Migration
  def change
    create_table :internet_deal_attributes do |t|
    	t.belongs_to :deal, index: true
        t.float	    :download
    	t.float 	:upload
    	t.float 	:data
    	t.string 	:email
    	t.string 	:online_storage
    	t.text 		:wifi_hotspot_networks
        t.boolean   :static_ip
    	t.text		:equipment
    	t.text		:installation
    	t.string	:activation
      	t.timestamps null: false
    end
    add_foreign_key :internet_deal_attributes, :deals
  end
end
