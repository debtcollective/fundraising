# frozen_string_literal: true

require "rails_helper"

RSpec.describe MembershipsController, type: :controller do
  describe "PUT #update_amount" do
    before { StripeMock.start }
    after { StripeMock.stop }

    it "with valid amount it updates the membership amount" do
      user = FactoryBot.create(:user_with_subscription_and_stripe, email: "example@debtcollective.org")
      subscription = user.subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update_amount, params: {membership: {amount: 10}}
      subscription.reload

      expect(response.status).to eq(302)
      expect(subscription.amount).to eq(10)
    end

    it "doesn't update the amount if it's less than 5 USD" do
      user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
      subscription = user.subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update_amount, params: {membership: {amount: 4}}
      subscription.reload

      expect(response.status).to eq(200)
      expect(subscription.amount).not_to eq(4)
    end

    it "doesn't update the amount if the user doesn't have a valid payment method" do
      user = FactoryBot.create(:user, email: "example@debtcollective.org")
      subscription = FactoryBot.create(:subscription, amount: 0, user_id: user.id)

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

      put :update_amount, params: {membership: {amount: 10}}
      subscription.reload

      expect(response.status).to eq(200)
      expect(subscription.zero_amount?).to eq(true)
    end
  end

  describe "PUT #update_card" do
    before { StripeMock.start }
    after { StripeMock.stop }
    before(:each) do
      request.accept = "application/json"
    end

    let(:stripe_helper) { StripeMock.create_test_helper }

    context "without a pending payment" do
      context "with valid credit card" do
        it "it updates correctly" do
          user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
          stripe_customer = Stripe::Customer.create(email: user.email)
          user.update(stripe_id: stripe_customer.id)
          subscription = user.subscription
          allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

          params = {
            address_city: "city",
            address_country_code: "US",
            address_line1: "line1",
            address_state: "state",
            address_zip: 33106,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            stripe_card_id: "card_123",
            stripe_card_last4: "4242",
            stripe_token: stripe_helper.generate_card_token
          }

          put :update_card, params: {membership: params}
          subscription.reload

          expect(response).to have_http_status(200)
          expect(subscription.metadata["payment_method"]["last4"]).to eq("4242")
        end
      end
    end

    context "with a pending payment" do
      context "with valid credit card" do
        it "it updates correctly and charges the card" do
          user = FactoryBot.create(:user, email: "example@debtcollective.org")
          subscription = FactoryBot.create(:subscription_beyond_subscription_period, user_id: user.id, status: :overdue)
          stripe_customer = Stripe::Customer.create(email: user.email)
          user.update(stripe_id: stripe_customer.id)
          allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

          params = {
            address_city: "city",
            address_country_code: "US",
            address_line1: "line1",
            address_state: "state",
            address_zip: 33106,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            stripe_card_id: "card_123",
            stripe_card_last4: "4242",
            stripe_token: stripe_helper.generate_card_token
          }

          put :update_card, params: {membership: params}
          subscription.reload
          donation = subscription.donations.last

          expect(response).to have_http_status(200)
          expect(subscription.metadata["payment_method"]["last4"]).to eq("4242")
          expect(subscription.donations.count).to eq(1)
          expect(subscription.overdue?).to eq(false)
          expect(donation.amount).to eq(subscription.amount)
        end
      end

      context "with invalid credit card" do
        it "it returns an error" do
          user = FactoryBot.create(:user, email: "example@debtcollective.org")
          subscription = FactoryBot.create(:subscription_beyond_subscription_period, user_id: user.id, status: :overdue)
          stripe_customer = Stripe::Customer.create(email: user.email)
          user.update(stripe_id: stripe_customer.id)
          allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))

          StripeMock.prepare_card_error(:card_declined)

          params = {
            address_city: "city",
            address_country_code: "US",
            address_line1: "line1",
            address_state: "state",
            address_zip: 33106,
            first_name: Faker::Name.first_name,
            last_name: Faker::Name.last_name,
            stripe_card_id: "card_123",
            stripe_card_last4: "4242",
            stripe_token: stripe_helper.generate_card_token
          }

          put :update_card, params: {membership: params}
          subscription.reload
          donation = subscription.donations.last
          json = JSON.parse(response.body)

          expect(response).to have_http_status(422)
          expect(json["status"]).to eq("failed")
          expect(subscription.metadata["payment_method"]["last4"]).to eq("4242")
          expect(subscription.donations.count).to eq(0)
          expect(subscription.overdue?).to eq(true)
          expect(donation).to be_nil
        end
      end
    end
  end

  describe "PUT #pause" do
    it "it pauses the membership" do
      user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
      subscription = user.subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))
      expect(subscription.paused?).to eq(false)

      put :pause
      subscription.reload

      expect(response.status).to eq(302)
      expect(subscription.paused?).to eq(true)
    end
  end

  describe "PUT #resume" do
    it "it activates the membership" do
      user = FactoryBot.create(:user_with_subscription, email: "example@debtcollective.org")
      subscription = user.subscription

      allow_any_instance_of(SessionProvider).to receive(:current_user).and_return(CurrentUser.new(user))
      expect(subscription.paused?).to eq(false)

      put :pause
      subscription.reload

      expect(response.status).to eq(302)
      expect(subscription.paused?).to eq(true)
    end
  end
end
