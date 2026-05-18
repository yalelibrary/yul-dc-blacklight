# frozen_string_literal: true
require 'rails_helper'

RSpec.describe AccessHelper, helper: true, style: true do
  let(:user) { FactoryBot.create(:user, netid: 'net_id', sub: 'sub-123') }
  let(:document) { SolrDocument.new(id: '12345', visibility_ssi: 'Open with Permission') }
  let(:management_url) { "#{ENV['MANAGEMENT_HOST']}/api/permission_sets/#{document.id}/#{user.netid}" }
  let(:auth_header) { { 'Authorization' => "Bearer #{ENV['OWP_AUTH_TOKEN']}" } }

  def stub_admin_response(is_admin)
    stub_request(:get, management_url)
      .with(headers: auth_header)
      .to_return(status: 200, body: %({"is_admin_or_approver?": #{is_admin}}))
  end

  def stub_session(signed_in_at: nil)
    session = signed_in_at ? { signed_in_at: signed_in_at } : {}
    allow(helper).to receive(:session).and_return(session.with_indifferent_access)
  end

  before { allow(helper).to receive(:params).and_return({}) }

  describe '#admin_session_expired?' do
    before { allow(helper).to receive(:current_user).and_return(user) }

    it 'returns true when signed_in_at is missing (fail closed)' do
      stub_session
      expect(helper.admin_session_expired?).to eq(true)
    end

    it 'returns false within the 12-hour window' do
      stub_session(signed_in_at: 1.hour.ago.to_i)
      expect(helper.admin_session_expired?).to eq(false)
    end

    it 'returns true once 12+ hours have elapsed since sign-in' do
      stub_session(signed_in_at: 13.hours.ago.to_i)
      expect(helper.admin_session_expired?).to eq(true)
    end

    it 'returns true at exactly the 12-hour boundary' do
      stub_session(signed_in_at: 12.hours.ago.to_i)
      expect(helper.admin_session_expired?).to eq(true)
    end
  end

  describe '#admin_of_owp?' do
    context 'when no user is signed in' do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it 'returns nil' do
        expect(helper.admin_of_owp?(document)).to be_nil
      end
    end

    context 'when user is signed in' do
      before { allow(helper).to receive(:current_user).and_return(user) }

      it 'grants admin when credentials say yes and within window' do
        stub_admin_response(true)
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(true)
      end

      it 'denies when credentials say yes but past the step-up window' do
        stub_admin_response(true)
        stub_session(signed_in_at: 13.hours.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(false)
      end

      it 'denies when credentials say no, even within the window' do
        stub_admin_response(false)
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(false)
      end

      it 'denies when signed_in_at is missing (fail closed)' do
        stub_admin_response(true)
        stub_session
        expect(helper.admin_of_owp?(document)).to eq(false)
      end

      it 'denies when management returns non-200' do
        stub_request(:get, management_url).to_return(status: 500, body: '')
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(false)
      end

      it 'denies when management returns malformed JSON' do
        stub_request(:get, management_url).to_return(status: 200, body: '<html>non-JSON</html>')
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(false)
      end

      it 'rejects a string "true" (server must emit a JSON boolean)' do
        stub_request(:get, management_url).to_return(status: 200, body: '{"is_admin_or_approver?": "true"}')
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_of_owp?(document)).to eq(false)
      end
    end
  end

  describe '#admin_reauth_required?' do
    context 'when no user is signed in' do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it 'returns false' do
        expect(helper.admin_reauth_required?(document)).to eq(false)
      end
    end

    context 'when signed in but not admin' do
      before { allow(helper).to receive(:current_user).and_return(user) }

      it 'returns false even past the window — non-admins never see step-up' do
        stub_admin_response(false)
        stub_session(signed_in_at: 13.hours.ago.to_i)
        expect(helper.admin_reauth_required?(document)).to eq(false)
      end
    end

    context 'when admin within the window' do
      before { allow(helper).to receive(:current_user).and_return(user) }

      it 'returns false (admin is currently granted)' do
        stub_admin_response(true)
        stub_session(signed_in_at: 1.hour.ago.to_i)
        expect(helper.admin_reauth_required?(document)).to eq(false)
      end
    end

    context 'when admin past the window' do
      before { allow(helper).to receive(:current_user).and_return(user) }

      it 'returns true (sign-in prompt should be shown)' do
        stub_admin_response(true)
        stub_session(signed_in_at: 13.hours.ago.to_i)
        expect(helper.admin_reauth_required?(document)).to eq(true)
      end
    end
  end

  describe '#restriction_message for Open with Permission' do
    before { allow(helper).to receive(:current_user).and_return(user) }

    context 'admin past the step-up window' do
      before do
        stub_admin_response(true)
        stub_session(signed_in_at: 13.hours.ago.to_i)
      end

      it 'returns the step-up sign-out prompt with a sign-out link' do
        message = helper.restriction_message(document)
        expect(message).to include('admin session has expired')
        expect(message).to include('sign out')
        expect(message).to match(/href="[^"]*sign_out"/)
      end
    end

    context 'non-admin user' do
      before do
        stub_admin_response(false)
        stub_session(signed_in_at: 1.hour.ago.to_i)
      end

      it 'returns the request-permission prompt, not the step-up one' do
        message = helper.restriction_message(document)
        expect(message).to include('request permission')
        expect(message).not_to include('admin session has expired')
      end
    end

    context 'admin within the step-up window' do
      before do
        stub_admin_response(true)
        stub_session(signed_in_at: 1.hour.ago.to_i)
      end

      it 'still falls through to the request-permission prompt (restriction_message only fires when access is denied)' do
        message = helper.restriction_message(document)
        expect(message).to include('request permission')
        expect(message).not_to include('admin session has expired')
      end
    end
  end
end
