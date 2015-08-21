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
end
