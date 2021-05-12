# frozen_string_literal: true

require "recaptcha"

class ChargesController < ApplicationController
  before_action :set_funds, only: %i[new create]
  before_action :set_fund_by_slug, only: :new
  before_action :set_fund_by_id, only: :create

  def new
  end

  def create
    # ignore captcha on json requests
    unless request.format.json?
      return render "new" unless verify_recaptcha
    end

    # check if user is a bot using token recaptcha
    is_human = verify_recaptcha(action: "donate", minimum_score: 0.5, secret_key: ENV["RECAPTCHA_V3_SECRET_KEY"])
    # if users is a bot then return error
    unless is_human
      message = "Oops! Something went wrong. Please try again"
      error = "Human validation has failed"
      return render json: {status: "failed", errors: [error], message: message}, status: :unprocessable_entity
    end

    donation_params =
      charge_params.to_h.merge(
        {
          customer_ip: request.remote_ip,
          fund_id: @fund.id
        }
      )

    donation, errors = DonationService.new(donation_params, current_user).execute

    respond_to do |format|
      if donation.persisted?
        # send thank you email
        DonationMailer.thank_you_email(donation: donation).deliver_later

        message = I18n.t(
          "charge.alerts.success",
          amount: ActionController::Base.helpers.number_to_currency(donation.amount)
        )

        format.html do
          flash[:success] = message
          redirect_to thank_you_path
        end
        format.json { render json: {status: "succeeded", message: message}, status: :ok }
      else
        format.html do
          error = "Oops! Something went wrong. Please try again"

          if errors["base"].any?
            error = errors["base"].first
          end

          flash[:error] = error
          render :new
        end
        format.json { render json: {status: "failed", errors: errors.messages}, status: :unprocessable_entity }
      end
    end
  end

  private

  def charge_params
    params.require(:charge).permit(
      :address_city,
      :address_country_code,
      :address_line1,
      :address_zip,
      :amount,
      :email,
      :fund_id,
      :name,
      :phone_number,
      :stripe_token
    )
  end

  def set_funds
    @funds = Fund.all
  end

  def set_fund_by_slug
    fund_slug = params[:fund]

    @fund = Fund.find_by(slug: fund_slug) if fund_slug
    @fund ||= Fund.default
  end

  def set_fund_by_id
    fund_id = charge_params[:fund_id]

    @fund = Fund.find_by(id: fund_id) if fund_id
    @fund ||= Fund.default
  end
end
