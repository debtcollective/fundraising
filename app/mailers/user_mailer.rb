class UserMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.welcome_email.subject
  #
  default from: ENV["MAIL_FROM"]

  def welcome_email(user:)
    @user = user
    @subscription = user.active_subscription
    email = @user.email
    @email_login_url = email_token_user_confirmations_url(email_token: @user.email_token)

    mail to: email, from: ENV["MAIL_FROM"]
  end

  def confirmation_email(user:)
    @user = user
    @confirmation_token = @user.confirmation_token
    email = @user.email

    mail to: email, from: ENV["MAIL_FROM"]
  end
end
