class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.role? 'super_admin'
      can :manage, :all
    elsif user.role? 'admin'
      can :read, [User, ServiceCategory, ServiceDeal, ServicePreference]  
    end  

  end
end
