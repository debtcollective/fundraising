# frozen_string_literal: true

class CurrentUser < Delegator
  attr_reader :user, :new_record
  alias_method :__getobj__, :user

  def initialize(user, payload = {}, new_record = false)
    @user = user
    @payload = payload
    @new_record = new_record
  end

  def new_record?
    new_record
  end

  def groups
    @payload["groups"]
  end

  def card_background_url
    @payload["card_background_url"]
  end

  def profile_background_url
    @payload["profile_background_url"]
  end

  def admin?
    !!@user.admin || @payload["groups"].include?(ENV["DISCOURSE_ADMIN_ROLE"])
  end

  def moderator?
    !!@payload["moderator"]
  end

  def as_json(options = {})
    options[:only] = [:id, :name, :email, :external_id]
    options[:methods] = [:active_subscription, :confirmed?]
    json = super(options)
    json["confirmed"] = json.delete("confirmed?")
    json["subscription"] = json.delete("active_subscription")

    json
  end
end
