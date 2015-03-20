class AddImageToDeals < ActiveRecord::Migration
  def change
  	add_attachment :deals, :deal_image
  end
end
