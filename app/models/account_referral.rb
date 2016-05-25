class AccountReferral < ActiveRecord::Base
	belongs_to :referral, class_name: "AppUser"
	belongs_to :referrer, class_name: "AppUser"
 
	validates_uniqueness_of :referrer_id
end
