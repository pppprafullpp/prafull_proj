class AppUser < ActiveRecord::Base
  #before_save :encrypt_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:recoverable, :rememberable, :trackable
  has_many :service_preferences, dependent: :destroy
  has_one :notification, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }  #, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  #def as_json(opts={})
  #  json = super(opts)
  #  Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  #end
  
end
