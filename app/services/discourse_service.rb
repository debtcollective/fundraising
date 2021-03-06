class DiscourseService
  attr_reader :user, :client

  # This is the map to match custom_fields with Discourse user fields
  USER_FIELDS_MAP = {
    "1": "address_state",
    "2": "address_zip",
    "3": "phone_number",
    "4": "address_city"
  }

  def initialize(user)
    @user = user

    @client = DiscourseApi::Client.new(ENV["DISCOURSE_URL"])
    @client.api_key = ENV["DISCOURSE_API_KEY"]
    @client.api_username = ENV["DISCOURSE_USERNAME"]
  end

  # Invite user via email
  def invite_user
    client.invite_user({
      email: user.email,
      group_names: "",
      custom_message: I18n.t("discourse_service.invite_custom_message")
    })
  end

  def create_user
    password = SecureRandom.hex(rand(24...32))

    client.create_user({
      email: user.email,
      name: user.name,
      password: password,
      active: true,
      approved: true,
      user_fields: user_fields,
      username: nil
    })
  end

  def user_fields
    user_fields_hash = {}
    USER_FIELDS_MAP.each { |key, sym| user_fields_hash[key] = user.custom_fields.fetch(sym, "") }

    user_fields_hash
  end

  def update_user
    client.update_user(user.username, {
      user_fields: user_fields
    })&.body
  end

  # This is used to create an email login link
  def create_email_token
    client.post("/u/email-token.json", {login: user.email})
  end

  # Check if username is available
  def check_username(username)
    client.check_username(username)
  end

  # Find user by email
  #
  # email - String - valid email
  #
  # Returns the User or nil if no user was found
  def find_user_by_email(email: user&.email)
    users = client.list_users("active", {
      filter: email,
      order: "ascending",
      page: 1
    })

    users.first
  end
end
