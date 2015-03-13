class AppUser < ActiveRecord::Base
  #before_save :encrypt_password
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:recoverable, :rememberable, :trackable
  has_many :service_preferences

  def as_json(opts={})
    json = super(opts)
    Hash[*json.map{|k, v| [k, v || ""]}.flatten]
  end

  #def encrypt_password
  #	byebug
  #  if password.present?
  #    self.password_salt = BCrypt::Engine.generate_salt
  #    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  #  end
  #end

  #def self.authenticate(email, password)
  #  user = find_by_email(email)
  #  if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
  #    user
  #  end
  #end

end
