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
  #has_many :comments, dependent: :destroy
  #has_many :ratings, dependent: :destroy
  mount_uploader :avatar, ImageUploader

  def avatar_url
      avatar.url
  end

  def as_json(opts={})
      json = super(opts)
      Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end
  
end
