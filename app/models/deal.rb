class Deal < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :service_provider
	has_many :comments, dependent: :destroy
	has_many :ratings, dependent: :destroy

	before_save :create_category_name
	before_save :create_provider_name

	has_attached_file :deal_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }  #, :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :deal_image, :content_type => /\Aimage\/.*\Z/

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
  
  	def deal_image_url
		deal_image.url(:medium)
	end

	def average_rating
		self.ratings.average(:rating_point)
	end

	def rating_count
		self.ratings.count
	end

	private
	def create_category_name
		self.service_category_name = self.service_category.name
	end
	def create_provider_name
		self.service_provider_name = self.service_provider.name
	end
end
