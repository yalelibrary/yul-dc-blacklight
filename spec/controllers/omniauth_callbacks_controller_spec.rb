# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OmniauthCallbacksController do
  include Devise::Test::ControllerHelpers
  let(:devise_mapping) { 'devise.mapping' }
  let(:omniauth_auth) { 'omniauth.auth' }

  describe 'when user exists' do
    before do
      User.create(provider: 'openid_connect',
                  uid: 'handsome_dan',
                  sub: '3456789098765434567890987654',
                  netid: 'hd345',
                  email: 'test@yale.edu')
      request.env[devise_mapping] = Devise.mappings[:user]
      request.env[omniauth_auth] = OmniAuth.config.mock_auth[:openid_connect]
    end
    # mock how cognito implements auth
    class Identities
      def issuer
        (ENV['SSO_ISS']).to_s
      end
    end
    OmniAuth.config.mock_auth[:openid_connect] =
      OmniAuth::AuthHash.new(
        provider: 'openid_connect',
        uid: 'handsome_dan',
        info: { email: 'test@yale.edu' },
        extra: {
          raw_info: {
            identities: [Identities.new],
            sub: '3456789098765434567890987654'
          }
        }
      )

    # If a user logs in and we can tell what page they were on before logging in it will redirect them to the page they were previously on
    context 'when origin is present' do
      before do
        request.env['omniauth.origin'] = '/yale-only-map-of-china'
      end

      it 'redirects to origin' do
        post :openid_connect
        expect(response.redirect_url).to eq 'http://test.host/yale-only-map-of-china'
      end
    end

    # If a user logs in and we cannot tell what page they were on before logging in it will redirect them to the home page
    context 'when origin is missing' do
      it 'redirects to dashboard' do
        post :openid_connect
        expect(response.redirect_url).to include 'http://test.host/'
      end
    end
  end

  describe 'when user has valid params' do
    before do
      request.env['omniauth.origin'] = '/yale-only-map-of-china'
      request.env[devise_mapping] = Devise.mappings[:user]
      request.env[omniauth_auth] = OmniAuth.config.mock_auth[:openid_connect]
    end
    OmniAuth.config.mock_auth[:openid_connect] =
      OmniAuth::AuthHash.new(
        provider: 'openid_connect',
        uid: 'handsome_stan',
        info: { email: 'hs_test@yale.edu' },
        extra: {
          raw_info: {
            identities: [Identities.new],
            sub: 'sub_id'
          }
        }
      )

    it 'can create a new user' do
      auth = {
        provider: 'openid_connect',
        uid: 'handsome_stan',
        info: { email: 'hs_test@yale.edu' },
        extra: {
          raw_info: {
            identities: [Identities.new],
            sub: 'sub_id'
          }
        }
      }
      post :openid_connect, params: auth
      expect(response.redirect_url).to eq 'http://test.host/yale-only-map-of-china'
      expect(User.where(uid: 'handsome_stan').count).to eq 1
    end
  end

  describe 'when user has invalid params' do
    before do
      request.env[devise_mapping] = Devise.mappings[:user]
      request.env[omniauth_auth] = OmniAuth.config.mock_auth[:not_cas]
    end
    OmniAuth.config.mock_auth[:not_cas] =
      OmniAuth::AuthHash.new(
        provider: 'not_cas',
        uid: 'guapo_stan',
        info: { email: 'gs_test@yale.edu' },
        extra: {
          raw_info: {
            identities: [Identities.new],
            sub: '2345678987654'
          }
        }
      )

    it 'can redirect to root path' do
      auth = {
        provider: 'not_cas',
        uid: 'guapo_stan',
        info: { email: 'gs_test@yale.edu' },
        extra: {
          raw_info: {
            identities: [Identities.new],
            sub: '2345678987654'
          }
        }
      }
      post :openid_connect, params: auth
      expect(response.redirect_url).to eq 'http://test.host/'
    end
  end

  describe 'Collections AI access' do
    def auth_hash(uid:, sub:, groups: nil, yale: true)
      raw_info = { sub: sub }
      raw_info[:identities] = [Identities.new] if yale
      raw_info['cognito:groups'] = groups unless groups.nil?
      OmniAuth::AuthHash.new(
        provider: 'openid_connect',
        uid: uid,
        info: { email: "#{uid}@yale.edu" },
        extra: { raw_info: raw_info }
      )
    end

    before do
      request.env[devise_mapping] = Devise.mappings[:user]
    end

    context 'when a Yale user is in an authorized Cognito group' do
      before do
        request.env[omniauth_auth] = auth_hash(uid: 'ai_dan', sub: 'ai_sub_1', groups: ['ai-user'])
      end

      it 'grants AI access on the user record' do
        post :openid_connect
        expect(User.find_by(uid: 'ai_dan').ai_user).to be true
      end
    end

    context 'when a Yale user is in no authorized Cognito group' do
      before do
        request.env[omniauth_auth] = auth_hash(uid: 'plain_dan', sub: 'ai_sub_2', groups: ['some-other-group'])
      end

      it 'does not grant AI access' do
        post :openid_connect
        expect(User.find_by(uid: 'plain_dan').ai_user).to be false
      end
    end

    context 'when the cognito:groups claim is absent' do
      before do
        request.env[omniauth_auth] = auth_hash(uid: 'no_groups_dan', sub: 'ai_sub_3')
      end

      it 'does not grant AI access' do
        post :openid_connect
        expect(User.find_by(uid: 'no_groups_dan').ai_user).to be false
      end
    end

    context 'when a non-Yale user without a netid is in an authorized Cognito group' do
      before do
        request.env[omniauth_auth] = auth_hash(uid: 'ai_stan', sub: 'ai_sub_4',
                                               groups: ['org:LibIT:Cognito:collections-ai-users'], yale: false)
      end

      it 'grants AI access on the user record' do
        post :openid_connect
        user = User.find_by(uid: 'ai_stan')
        expect(user.netid).to be_nil
        expect(user.ai_user).to be true
      end
    end

    context 'when an authorized user is no longer in the Cognito group' do
      before do
        User.create(provider: 'openid_connect', uid: 'former_ai_dan', sub: 'ai_sub_5',
                    email: 'former_ai_dan@yale.edu', ai_user: true)
        request.env[omniauth_auth] = auth_hash(uid: 'former_ai_dan', sub: 'ai_sub_5',
                                               groups: ['some-other-group'], yale: false)
      end

      it 'revokes AI access at the next login' do
        post :openid_connect
        expect(User.find_by(uid: 'former_ai_dan').ai_user).to be false
      end
    end
  end
end
