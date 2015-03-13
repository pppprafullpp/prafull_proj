class ServicePreference < ActiveRecord::Base
	belongs_to :app_users
	has_many :deal, through: :service_category

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
  	
end
