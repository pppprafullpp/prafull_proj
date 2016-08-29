class AppUserMailer < ApplicationMailer
  default from: "servicedeal@spa-systems.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.app_user_mailer.recover_password_email.subject
  #
  def recover_password_email()
    app_user=AppUser.find_by_email("apoorv@sp-assurance.com")
    recipient = app_user.email
    @secret_p = app_user.unhashed_password
    @name=Base64.decode64(app_user.first_name) + " " + Base64.decode64(app_user.last_name)
    mail(:to => recipient, :subject => "Service-Deal recover password") rescue nil
  end

  def cashout_email(app_user,cashout)
    recipient = "ram.garg@spa-systems.com"
    @reedeem_amount = cashout.reedeem_amount
    @email = cashout.email_id
    @name = app_user.first_name
    mail(:to => recipient, :subject => "Cashout") rescue nil
  end

  def contact_us(name,email,subject,message)
    recipient = "amit.pandey@spa-systems.com,apoorv@sp-assurance.com,ankit@spa-systems.com"
    @name = name;@email = email; @subject = subject.titleize; @message = message
    mail(:to => recipient, :cc => @email,:subject => "New Query: #{@subject}") rescue nil
  end
  def send_verification_mail(id,code)
    @secure_token=code
    puts @secure_token
    @user_id=id
    email=AppUser.find(id).email
    mail(:to=>email,:subject=>"Service Dealz:Verification mail")
  end
end
