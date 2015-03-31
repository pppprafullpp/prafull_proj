class Comment < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal
	before_save :create_app_user_name

	private
	def create_app_user_name
		@app_user = AppUser.find_by_id(app_user_id)
		self.app_user_name = @app_user.first_name
	end
	
end
