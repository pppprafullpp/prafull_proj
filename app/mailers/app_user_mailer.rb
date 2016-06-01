class AppUserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.app_user_mailer.recover_password_email.subject
  #
  def recover_password_email(app_user)
    recipient = app_user.email
    @secret_p = app_user.unhashed_password
    mail(to: recipient, subject: "Service-Deal recover password") rescue nil
  end

  def cashout_email(app_user,cashout)
    recipient = "ram.garg@spa-systems.com"
    @reedeem_amount = cashout.reedeem_amount
    @email = cashout.email_id
    @name = app_user.first_name
    mail(to: recipient, subject: "Cashout") rescue nil
  end
end
