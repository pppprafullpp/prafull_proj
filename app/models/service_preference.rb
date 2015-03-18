class ServicePreference < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :service_category
	belongs_to :service_provider

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
  	
end
