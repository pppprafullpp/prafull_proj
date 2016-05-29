class AccountReferral < ActiveRecord::Base
	belongs_to :referral, class_name: "AppUser"
	belongs_to :referrer, class_name: "AppUser"
 
	validates_uniqueness_of :referrer_id
	
	def as_json(options = {})
    json = super(options)
    json['refer_message'] = refer_message(options[:param_for_message])
    json
	end

	def refer_message(user_id)
		if self.referrer_id == user_id.to_i
			return "You have used your one time referral."
		elsif self.referral_id == user_id.to_i
			referrer = AppUser.find_by_id(self.referrer_id)
			return "You earned $10 as #{referrer.first_name.capitalize} joins ServiceDeals."
		end
	end
end
