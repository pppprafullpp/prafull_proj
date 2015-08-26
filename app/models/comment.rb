class Comment < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal

	def app_user_name
		self.app_user.first_name + ' ' + self.app_user.last_name
	end
	
end
