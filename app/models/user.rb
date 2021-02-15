# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                   :bigint           not null, primary key
#  activated_at         :datetime
#  active               :boolean          default(FALSE)
#  admin                :boolean          default(FALSE)
#  avatar_url           :string
#  banned               :boolean          default(FALSE)
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  custom_fields        :jsonb
#  email                :string
#  email_token          :string
#  name                 :string
#  username             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :bigint
#  stripe_id            :string
#
class User < ApplicationRecord
  include ActionView::Helpers::DateHelper

  SSO_ATTRIBUTES = %w[
    admin
    avatar_url
    banned
    email
    username
    external_id
  ].freeze

  has_many :subscriptions
  has_many :donations
  has_many :user_plan_changes

  def self.find_or_create_from_sso(payload)
    email = payload.fetch("email")&.downcase
    external_id = payload.fetch("external_id")

    # find by email when the external_id is nil
    # this is the case when the user comes here for the first time
    # after creating a Discourse account and having a valid session
    user = User.find_by(email: email, external_id: nil)

    # if no user is found, we try to do find a user external_id
    user ||= User.find_or_initialize_by(external_id: external_id)

    # Update SSO fields
    SSO_ATTRIBUTES.each do |sso_attribute|
      user[sso_attribute] = payload[sso_attribute]
    end

    new_record = user.new_record?

    user.save

    [user, new_record]
  end

  def self.send_confirmation_instructions(email:)
    user = User.find_by_email(email.downcase)

    if user
      confirmation_token = user.confirmation_token || SecureRandom.hex(20)
      user.update(confirmation_token: confirmation_token, confirmation_sent_at: DateTime.now)
      UserMailer.confirmation_email(user: user).deliver_later
    else
      user = User.new
      user.errors.add(:base, "User not found")
    end

    user
  end

  def self.confirm_by_token(confirmation_token)
    user = User.find_by_confirmation_token(confirmation_token)

    if user
      user.update(confirmation_token: nil, confirmed_at: DateTime.now)
    else
      user = User.new
      user.errors.add(:base, "Invalid confirmation token")
    end

    user
  end

  def admin?
    !!admin
  end

  def activate!
    update!(active: true, activated_at: DateTime.now)
  end

  # TODO: We are getting first_name and last_name from users when the join the union
  #   The idea is to add those fields to the model and remove these methods.
  def first_name
    name = self.name.to_s
    name.split(" ").first
  end

  def last_name
    name = self.name.to_s
    _, *last_name = name.split(" ")
    last_name.join(" ")
  end

  def phone_number
    custom_fields["phone_number"]
  end

  def email_token
    custom_fields["email_token"]
  end

  def confirmed?
    external_id.present? || confirmed_at.present?
  end

  def pending_plan_change
    @pending_plan_change ||= user_plan_changes.where(status: :pending).first
  end

  def active_subscription
    @active_subscription ||= subscriptions.where(active: true).last
  end

  def find_stripe_customer
    return Stripe::Customer.retrieve(stripe_id) if stripe_id
  end

  # return all emails downcase
  def email
    super()&.downcase
  end
end
