class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    # TODO: find a better way to do this
    @user = User.find_by(email: "user_mailer_welcome_email_preview@example.com")
    @user ||= FactoryBot.create(:user_with_subscription, email: "user_mailer_welcome_email_preview@example.com", email_token: SecureRandom.hex(20))

    UserMailer.welcome_email(user: @user)
  end
end
