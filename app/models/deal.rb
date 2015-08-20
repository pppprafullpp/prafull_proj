class Deal < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :service_provider
	has_many :comments, dependent: :destroy
	has_many :ratings, dependent: :destroy

	before_save :create_category_name
	before_save :create_provider_name

	mount_uploader :image, ImageUploader

	validates_presence_of :title, :image, :zip, :short_description, :detail_description, :price, :url, :you_save_text, :start_date, :end_date

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end

  	def deal_image_url
  		image.url
  	end

	#def deal_image=(obj)
    #	super(obj)
    #	# Put your callbacks here, e.g.
    #	self.moderated = false  
  	#end

	def average_rating
		self.ratings.average(:rating_point)
	end

	def rating_count
		self.ratings.count
	end

	def deal_price
		sprintf '%.2f', self.price if self.price.present?
	end

	private
	def create_category_name
		self.service_category_name = self.service_category.name
	end
	def create_provider_name
		self.service_provider_name = self.service_provider.name
	end
	
end
