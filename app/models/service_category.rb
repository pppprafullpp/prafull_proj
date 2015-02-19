class ServiceCategory < ActiveRecord::Base
	has_many :service_deals
end
