class ServicePreference < ActiveRecord::Base
	belongs_to :app_users
	has_many :deal, through: :service_category

	
end
