class ServiceCategory < ActiveRecord::Base
	has_many :service_deals
	has_many :service_providers
end
