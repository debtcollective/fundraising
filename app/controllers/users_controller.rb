# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user = User.new(user_params)

    respond_to do |format|
      if user.save
        format.json { render json: {status: "success", user: user.as_json}, status: :created }
      else
        format.json { render json: {status: "failed", errors: user.errors.messages, message: ""}, status: :unprocessable_entity }
      end
    end
  end

  def current
    respond_to do |format|
      if current_user.present?
        format.json { render json: current_user.as_json, status: :ok }
      else
        format.json { render json: nil, status: :not_found }
      end
    end
  end

  def user_params
    params.require(:user).permit(
      :email,
      user_profile_attributes: [
        :first_name,
        :last_name,
        :phone_number,
        :address_line1,
        :address_city,
        :address_state,
        :address_zip,
        :address_country,
        :address_country_code
      ]
    )
  end
end
