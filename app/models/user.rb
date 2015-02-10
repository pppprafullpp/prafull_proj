class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable
  
  validates :email, :presence => true, :uniqueness => true
  validates :password, :presence => true, :confirmation => true, :on => :create

	def is_super_admin?
		return !!(self.role == 'super_admin')
	end
end
