class ServiceProviderChecklist < ActiveRecord::Base
  belongs_to :service_category
  belongs_to :service_provider
end
