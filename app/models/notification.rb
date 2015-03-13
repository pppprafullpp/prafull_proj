class Notification < ActiveRecord::Base
	belongs_to :app_users

	def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end
end
