class Comment < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal
end
