class CreateAdditionalOfferZipcodeMaps < ActiveRecord::Migration
  def change
    create_table :additional_offer_zipcode_maps do |t|
      t.belongs_to :additional_offer, index: true
      t.belongs_to :zipcode, index: true
      t.timestamps null: false
    end
  end
end
