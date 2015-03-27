class Deal < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :service_provider
	has_many :comments, dependent: :destroy
	has_many :ratings, dependent: :destroy

	has_attached_file :deal_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }  #, :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :deal_image, :content_type => /\Aimage\/.*\Z/

	#def as_json(opts={})
    #	json = super(opts)
    #	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	#end
end
