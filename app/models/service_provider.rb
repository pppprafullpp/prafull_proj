class ServiceProvider < ActiveRecord::Base
	belongs_to :service_category
	has_many :deals, dependent: :destroy

	has_attached_file :logo, :styles => { :medium => "300x300>", :thumb => "100x100>" }  #, :default_url => "/images/:style/missing.png"
    validates_attachment_content_type :logo, :content_type => /\Aimage\/.*\Z/

	def as_json(opts={})
  		json = super(opts)
  		Hash[*json.map{|k, v| [k, v || ""]}.flatten]
	end

end
