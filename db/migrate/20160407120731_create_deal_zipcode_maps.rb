class CreateDealZipcodeMaps < ActiveRecord::Migration
  def change
    create_table :deal_zipcode_maps do |t|
      t.belongs_to :deal, index: true
      t.belongs_to :zipcode, index: true
      t.timestamps null: false
    end
  end
end
