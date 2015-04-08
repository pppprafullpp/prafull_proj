class ServiceProvider < ActiveRecord::Base
	belongs_to :service_category
	has_many :deals, dependent: :destroy

	mount_uploader :logo, ImageUploader

	def as_json(opts={})
  		json = super(opts)
  		Hash[*json.map{|k, v| [k, v || ""]}.flatten]
	end

	def provider_logo_url
  		logo.url
  	end

end
