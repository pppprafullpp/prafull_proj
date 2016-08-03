class AppUser < ActiveRecord::Base
  ##include Encrypt
  #before_save :encrypt_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:recoverable, :rememberable, :trackable
  has_many :service_preferences, dependent: :destroy
  has_one :notification, dependent: :destroy
  has_many :comment_ratings, dependent: :destroy
  has_many :subscribe_deals, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :user_gifts,:dependent => :destroy
  has_many :gifts, through: :user_gifts
  has_many :referrals, :class_name => "AccountReferral", :foreign_key => "referral_id",dependent: :destroy
  has_one :referrer, :class_name => "AccountReferral", :foreign_key => "referrer_id",dependent: :destroy
  has_many :app_user_addresses, dependent: :destroy
  has_many :business_app_users, dependent: :destroy
  has_many :refer_contact_details
  #has_many :comments, dependent: :destroy
  #has_many :ratings, dependent: :destroy
  mount_uploader :avatar, ImageUploader

  before_save :encode_data
  ##before_save :encrypt_data
  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true, :confirmation => true, :on => :create

  ## user type
  RESIDENCE = 'residence'
  BUSINESS = 'business'

  PRIMARY_ID = ["Driver License" , "Passport","State ID Card", "US Military Card", "US Military Department ID Card", "US Coast Guard Merchant Mariner Card", "EAD" ]
  SECONDARY_ID = ["Major credit card" , "Driver License","Passport"," State ID Card", "US Military Card", "US Military Department ID Card", "US Coast Guard Merchant Mariner Card", "EAD", "Birth certificate" ]
  USER_TYPES = [RESIDENCE,BUSINESS]

  def encrypt_data
    ##self.zip = encode_data({'data' => self.zip}) if self.zip.present?
  end

  def avatar_url
    avatar.url
  end

  def as_json(opts={})
    json = super(opts)
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  def self.encrypt(password)
    Digest::SHA1.hexdigest("#{password}")
  end

  def self.authenticate(email, password)
    user = self.select('id,first_name,last_name,email,encrypted_password,active,zip,user_type').where(:email => email).first
    if user.present? && password.present?
      user.valid_password?(password) ? user : nil
    else
      nil
    end
  end

  def self.update_app_user(params,app_user_id,order = nil)
    app_user = self.where(:id => app_user_id).first
    params[:app_user].each do |key,value|
      app_user[key] = value unless key == 'email'
    end
    if order.present?
      app_user.primary_id = order.primary_id
      app_user.secondary_id = order.secondary_id
      app_user.primary_id_number = order.primary_id_number
      app_user.secondary_id_number = order.secondary_id_number
    end
    if app_user.save!
      app_user
    else
      app_user
    end
  end
  def encode_data
    self.email =email.downcase
    self.first_name=Base64.encode64(first_name.downcase)
    self.last_name=Base64.encode64(last_name.downcase)
    # self.zip=Base64.encode64(zip)
    self.mobile=Base64.encode64(mobile) if mobile.present?
  end



end
