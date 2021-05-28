# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  describe "GET #current" do
    before(:each) do
      request.accept = "application/json"
    end

    it "returns 404 if no user authenticated" do
      get :current

      expect(response.status).to eq(404)
      expect(response.body).to eq("null")
    end

    it "returns user if authenticated" do
      user = FactoryBot.create(:user)
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      get :current
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json["id"]).to eq(user.id)
      expect(json["subscription"]).to eq(nil)
    end

    it "returns active membership if available" do
      user = FactoryBot.create(:user_with_subscription)
      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      get :current
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)
      expect(json["id"]).to eq(user.id)
      expect(json["subscription"]["id"]).to eq(user.subscription.id)
    end
  end

  describe "POST #create" do
    before(:each) do
      request.accept = "application/json"
    end

    context "happy" do
      it "returns 200 and the user" do
        valid_attributes = {
          user: {
            email: Faker::Internet.email,
            user_profile_attributes: {
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              address_city: Faker::Address.city,
              address_country_code: Faker::Address.country_code,
              address_line1: Faker::Address.street_address,
              address_zip: Faker::Address.zip_code,
              phone_number: Faker::PhoneNumber.cell_phone_in_e164
            }
          }
        }

        post :create, params: valid_attributes
        json_body = JSON.parse(response.body)

        expect(response.status).to eq(201)
        expect(json_body["status"]).to eq("success")
        expect(json_body["email"]).to eq(valid_attributes["email"])
      end
    end

    context "error" do
      it "returns 422 if the payload is not valid" do
        invalid_attributes = {
          user: {
            email: Faker::Internet.email,
            user_profile_attributes: {
              first_name: Faker::Name.first_name,
              last_name: Faker::Name.last_name,
              phone_number: Faker::PhoneNumber.cell_phone_in_e164
            }
          }
        }

        post :create, params: invalid_attributes
        json_body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(json_body["status"]).to eq("failed")
        expect(json_body["errors"]).to be_present
      end
    end
  end
end
