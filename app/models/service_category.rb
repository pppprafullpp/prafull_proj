class ServiceCategory < ActiveRecord::Base
	has_many :deals, :dependent => :destroy
	has_many :service_providers, :dependent => :destroy
	has_one :advertisement, :dependent => :destroy

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
end
