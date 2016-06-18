class OrderMailer < ApplicationMailer
  layout 'custom_mailer'
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.app_user_mailer.recover_password_email.subject
  #
  def order_confirmation(app_user,order)
    recipient = app_user.email
    @app_user = app_user
    @order = order
    mail(to: recipient, subject: "Service-Deal Order Confirmation# #{order.order_number}")
  end

end
