class Advertisement < ActiveRecord::Base
	belongs_to :service_category

	has_attached_file :ad_image, :styles => { :medium => "300x300>", :thumb => "100x100>" }
    validates_attachment_content_type :ad_image, :content_type => /\Aimage\/.*\Z/

    def ad_image_url
		ad_image.url(:medium)
	end

end
