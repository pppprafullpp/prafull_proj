class AddImageToAdvertisement < ActiveRecord::Migration
  def change
  	add_attachment :advertisements, :ad_image
  end
end
