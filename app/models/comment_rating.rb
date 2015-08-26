class CommentRating < ActiveRecord::Base
	belongs_to :app_user
	belongs_to :deal

	def app_user_name
		self.app_user.first_name + ' ' + self.app_user.last_name
	end

	def app_user_image_url
		self.app_user.avatar.url
	end

	def as_json(opts={})
  		json = super(opts)
  		Hash[*json.map{|k, v| [k, v || ""]}.flatten]
	end
end
