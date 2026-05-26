# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers
  include ActiveSupport::Testing::TimeHelpers

  controller do
    skip_before_action :ensure_guest_uid_authentication_key, raise: false

    def index
      render plain: current_user&.uid.to_s
    end
  end

  let(:user) do
    User.create!(
      provider: 'openid_connect',
      uid: 'handsome_dan',
      sub: 'sub-12345',
      netid: 'hd345',
      email: 'test@yale.edu'
    )
  end

  describe 'idle session timeout' do
    context 'when no user is signed in' do
      it 'leaves current_user as nil and does not set last_request_at' do
        get :index
        expect(response.body).to eq('')
        expect(session[:last_request_at]).to be_nil
      end
    end

    context 'when a user is signed in with recent activity' do
      before do
        sign_in user
        session[:last_request_at] = 1.hour.ago.to_i
      end

      it 'returns the user and refreshes the activity timestamp' do
        freeze_time = Time.current
        travel_to(freeze_time) do
          get :index
          expect(response.body).to eq(user.uid)
          expect(session[:last_request_at]).to eq(freeze_time.to_i)
        end
      end
    end

    context 'when the user has been idle past User.timeout_in' do
      before do
        sign_in user
        session[:last_request_at] = (User.timeout_in.to_i + 60).seconds.ago.to_i
      end

      it 'signs the user out and clears session timestamps' do
        get :index
        expect(response.body).to eq('')
        expect(controller.current_user).to be_nil
        expect(session[:last_request_at]).to be_nil
        expect(session[:signed_in_at]).to be_nil
      end
    end

    context 'when a steadily-active user crosses the original 12h window' do
      it 'stays signed in because each request resets last_request_at' do
        start = Time.current

        travel_to(start) do
          sign_in user
          session[:last_request_at] = start.to_i
        end

        travel_to(start + 11.hours) do
          get :index
          expect(response.body).to eq(user.uid)
        end

        travel_to(start + 22.hours) do
          get :index
          expect(response.body).to eq(user.uid)
        end
      end
    end

    context 'with a legacy session that has signed_in_at but no last_request_at' do
      before do
        sign_in user
        session.delete(:last_request_at)
        session[:signed_in_at] = 1.hour.ago.to_i
      end

      it 'falls back to signed_in_at for the timeout check' do
        get :index
        expect(response.body).to eq(user.uid)
        expect(session[:last_request_at]).not_to be_nil
      end
    end

    context 'when both timestamps are missing for a signed-in user' do
      before do
        sign_in user
        session.delete(:last_request_at)
        session.delete(:signed_in_at)
      end

      it 'fails closed and signs the user out' do
        get :index
        expect(response.body).to eq('')
        expect(controller.current_user).to be_nil
      end
    end
  end
end
