# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                      :bigint           not null, primary key
#  admin                   :boolean          default(FALSE)
#  avatar_url              :string
#  banned                  :boolean          default(FALSE)
#  confirmation_sent_at    :datetime
#  confirmed_at            :datetime
#  custom_fields           :jsonb
#  email                   :string
#  email_token             :string
#  name                    :string
#  registration_ip_address :inet
#  username                :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  external_id             :bigint
#  stripe_id               :string
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
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

  has_one :user_profile, autosave: true
  has_one :subscription
  has_many :donations

  validates :email, presence: true, 'valid_email_2/email': true, uniqueness: {case_sensitive: false}
  before_validation :normalize_attributes

  accepts_nested_attributes_for :user_profile

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

    # Since the user comes from SSO, we can confirm the account
    user.confirmed_at ||= DateTime.now

    new_record = user.new_record?
    user.save

    [user, new_record]
  end

  def confirm!
    update!(confirmed_at: DateTime.now)
  end

  def send_welcome_email
    UserMailer.welcome_email(user: self).deliver_later
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

  def confirmed?
    confirmed_at.present?
  end

  def pending_plan_change
    @pending_plan_change ||= user_plan_changes.where(status: :pending).first
  end

  def find_stripe_customer
    return Stripe::Customer.retrieve(stripe_id) if stripe_id
  end

  def find_or_create_user_profile
    return user_profile if user_profile.present?

    user_profile = build_user_profile(registration_email: email)

    # save without validations to initialize an empty user_profile
    user_profile.save(validate: false)

    user_profile
  end

  private

  def normalize_attributes
    self.email = email&.downcase
  end
end
