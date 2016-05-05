class Deal < ActiveRecord::Base
	belongs_to :service_category
	belongs_to :service_provider
	has_many :comment_ratings, dependent: :destroy
	has_many :subscribe_deals, dependent: :destroy
	has_many :trending_deals, dependent: :destroy
  has_many  :internet_deal_attributes, dependent: :destroy
  has_many  :telephone_deal_attributes, dependent: :destroy
  has_many  :cable_deal_attributes, dependent: :destroy
  has_many  :cellphone_deal_attributes, dependent: :destroy
  has_many  :bundle_deal_attributes, dependent: :destroy
  has_many  :additional_offers, dependent: :destroy
  has_and_belongs_to_many  :zipcodes, dependent: :destroy
  
  accepts_nested_attributes_for :internet_deal_attributes,:reject_if => :reject_internet, allow_destroy: true
  accepts_nested_attributes_for :telephone_deal_attributes,:reject_if => :reject_telephone, allow_destroy: true
  accepts_nested_attributes_for :cable_deal_attributes,:reject_if => :reject_cable, allow_destroy: true
  accepts_nested_attributes_for :cellphone_deal_attributes,:reject_if => :reject_cellphone, allow_destroy: true
  accepts_nested_attributes_for :bundle_deal_attributes,:reject_if => :reject_bundle, allow_destroy: true
  accepts_nested_attributes_for :additional_offers,:reject_if => :reject_additional, allow_destroy: true
  
	mount_uploader :image, ImageUploader

	validates_presence_of :service_category_id, :service_provider_id, :title, :short_description, :detail_description, :price, :url, :start_date, :end_date

  def as_json(opts={})
    	json = super(opts)
    	Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  	end

  	def self.import(file)
    	CSV.foreach(file.path, headers: true) do |row|
      	#deal_hash = row.to_hash # exclude the price field
      	deal_hash = { :id => row['ID'], 
      								:service_category_id => row['Service Category ID'], 
      								:service_provider_id => row['Service Provider ID'],
      								:title => row['Title'],
      								:state => row['State'], 
      								:city => row['City'], 
      								:zip => row['Zip'], 
      								:price => row['Price'], 
      								:upload_speed => row['Upload Speed'], 
      								:download_speed => row['Download Speed'], 
      								:free_channels => row['Free Channels'], 
      								:premium_channels => row['Premium Channels'], 
      								:data_plan => row['Data Plan'],
      								:data_speed => row['Data Speed'],
      								:domestic_call_minutes => row['Domestic Call Minutes'],
      								:international_call_minutes => row['International Call Minutes'],
      								:domestic_call_unlimited => row['Domestic Call Unlimited'],
      								:international_call_unlimited => row['International Call Unlimited'],
      								:bundle_combo => row['Bundle Combo'],
      								:is_active => row['Is Active'], 
      								:url => row['URL'],
      								:start_date => row['Start Date'],
      								:end_date => row['End Date'],
      								:short_description => row['Short Description'],
      								:detail_description => row['Detail Description'],
                      :image => row['Image'], 
                      :created_at => row['Created At'], 
                      :updated_at => row['Updated At'], 
                    }
      	deal = Deal.where(id: deal_hash[:id])

      	if deal.count == 1
        	deal.first.update_attributes(deal_hash.except("image"))
      	else
        	Deal.create!(deal_hash)
      	end # end if !service_category.nil?
    	end # end CSV.foreach
  	end # end self.import(file)

  	def deal_image_url
  		image.url
  	end

	#def deal_image=(obj)
    #	super(obj)
    #	# Put your callbacks here, e.g.
    #	self.moderated = false  
  	#end

	def average_rating
		self.comment_ratings.average(:rating_point)
	end

	def rating_count
		self.comment_ratings.count
	end

	def deal_price
    if self.cellphone_deal_attributes.present?
      cellphone=self.cellphone_deal_attributes.first
      equipment=cellphone.cellphone_equipments.first
      additional_offer=self.additional_offers.first
      effective_price=(cellphone.no_of_lines*cellphone.price_per_line)+cellphone.data_plan_price+cellphone.additional_data_price
      if equipment.present?
        effective_price+=equipment.price
      end
      if additional_offer.present?
        effective_price-=additional_offer.price
      end
      sprintf '%.2f', effective_price
    else
		  sprintf '%.2f', self.price if self.price.present?
    end
	end

  def service_category_name
    self.service_category.name
  end
  def service_provider_name
    self.service_provider.name
  end
  def additional_offer_title
    self.additional_offers.pluck('title') if self.additional_offers.present?
  end
  def additional_offer_detail
    self.additional_offers.pluck('description') if self.additional_offers.present?
  end
  def additional_offer_price_value
    self.additional_offers.pluck('price_value') if self.additional_offers.present?
  end

	private
  def reject_internet(attributes)
    if attributes[:download].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
  def reject_telephone(attributes)
    if attributes[:domestic_call_minutes].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
  def reject_cable(attributes)
    if attributes[:free_channels].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
  def reject_cellphone(attributes)
    if attributes[:domestic_call_minutes].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
  def reject_bundle(attributes)
    if attributes[:download].blank? && attributes[:domestic_call_minutes].blank? && attributes[:free_channels].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
	
  def reject_additional(attributes)
    if attributes[:title].blank?
      if attributes[:id].present?
        attributes.merge!({:_destroy => 1}) && false
      else
        true
      end
    end
  end
  
end
