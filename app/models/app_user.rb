class AppUser < ActiveRecord::Base
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

  before_save { self.email = email.downcase }
  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true, :confirmation => true, :on => :create

  ## user type
  RESIDENCE = 'residence'
  BUSINESS = 'business'

  USER_TYPES = [RESIDENCE,BUSINESS]

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
    user = self.select('id,first_name,last_name,email,encrypted_password,active').where(:email => email).first
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
    end
    if app_user.save!
      app_user
    else
      app_user
    end
  end

end

