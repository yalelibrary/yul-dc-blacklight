# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthCallbacksController do
  include Devise::Test::ControllerHelpers

  before do
    User.create(provider: 'cas',
                uid: 'handsome_dan')
    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:cas]
  end
  OmniAuth.config.mock_auth[:cas] =
    OmniAuth::AuthHash.new(
      provider: 'cas',
      uid: "handsome_dan"
    )

  # If a user logs in and we can tell what page they were on before logging in it will redirect them to the page they were previously on
  context "when origin is present" do
    before do
      request.env["omniauth.origin"] = '/yale-only-map-of-china'
    end

    it "redirects to origin" do
      post :cas
      expect(response.redirect_url).to eq 'http://test.host/yale-only-map-of-china'
    end
  end

  # If a user logs in and we cannot tell what page they were on before logging in it will redirect them to the home page
  context "when origin is missing" do
    it "redirects to dashboard" do
      post :cas
      expect(response.redirect_url).to include "http://test.host/"
    end
  end
end
