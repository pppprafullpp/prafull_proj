class Deal < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :service_provider
	has_many :comment_ratings, :dependent => :destroy
	has_many :subscribe_deals, dependent: :destroy
	has_many :trending_deals, dependent: :destroy

	before_save :create_category_name
	before_save :create_provider_name

	mount_uploader :image, ImageUploader

	validates_presence_of :title, :zip, :state, :short_description, :detail_description, :price, :url, :start_date, :end_date #:image

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end

  	def self.import(file)
    	CSV.foreach(file.path, headers: true) do |row|
      	#deal_hash = row.to_hash # exclude the price field
      	deal_hash = { :id => row['ID'], 
      								:service_category_id => row['Service Category ID'], 
      								:service_provider_id => row['Service Provider ID'],
      								:title => row['Title'],
      								:state => row['State'], 
      								:city => row['City'], 
      								:zip => row['Zip'], 
      								:price => row['Price'], 
      								:upload_speed => row['Upload Speed'], 
      								:download_speed => row['Download Speed'], 
      								:free_channels => row['Free Channels'], 
      								:premium_channels => row['Premium Channels'], 
      								:data_plan => row['Data Plan'],
      								:data_speed => row['Data Speed'],
      								:domestic_call_minutes => row['Domestic Call Minutes'],
      								:international_call_minutes => row['International Call Minutes'],
      								:domestic_call_unlimited => row['Domestic Call Unlimited'],
      								:international_call_unlimited => row['International Call Unlimited'],
      								:bundle_combo => row['Bundle Combo'],
      								:is_active => row['Is Active'], 
      								:url => row['URL'],
      								:start_date => row['Start Date'],
      								:end_date => row['End Date'],
      								:short_description => row['Short Description'],
      								:detail_description => row['Detail Description'],
                      :image => URI.parse(row['Logo']), 
                      :created_at => row['Created At'], 
                      :updated_at => row['Updated At'], 
                    }
      	deal = Deal.where(id: deal_hash["id"])

      	if deal.count == 1
        	deal.first.update_attributes(deal_hash.except("image"))
      	else
        	Deal.create!(deal_hash)
      	end # end if !service_category.nil?
    	end # end CSV.foreach
  	end # end self.import(file)

  	def deal_image_url
  		image.url
  	end

	#def deal_image=(obj)
    #	super(obj)
    #	# Put your callbacks here, e.g.
    #	self.moderated = false  
  	#end

	def average_rating
		self.comment_ratings.average(:rating_point)
	end

	def rating_count
		self.comment_ratings.count
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
