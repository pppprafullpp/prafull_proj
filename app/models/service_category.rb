class ServiceCategory < ActiveRecord::Base
	has_many :deals
	has_many :service_providers

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
end
