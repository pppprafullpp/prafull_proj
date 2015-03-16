class ServiceProvider < ActiveRecord::Base
	belongs_to :service_category
	has_many :deals, dependent: :destroy

	def as_json(opts={})
  		json = super(opts)
  		Hash[*json.map{|k, v| [k, v || ""]}.flatten]
	end

end
