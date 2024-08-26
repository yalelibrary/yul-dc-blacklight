# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Permission Requests', type: :system do
  let(:user) { FactoryBot.create(:user, netid: 'my5679', sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6e', uid: 'some_name', email: 'not_real@example.com') }
  let(:admin_user) { FactoryBot.create(:user, netid: 'mz5679', sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6f3', uid: 'some_other_name', email: 'not_real_either@example.com') }
  let(:owp_work_with_approved_permission) do
    {
      "id": "1618909",
      "title_tesim": ["Map of China"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["11111"]
    }
  end
  let(:owp_work_with_pending_permission) do
    {
      "id": "1718909",
      "title_tesim": ["Map of India"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["222222"]
    }
  end
  let(:owp_work_with_denied_permission) do
    {
      "id": "1818909",
      "title_tesim": ["Map of Australia"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["3333333"]
    }
  end
  let(:valid_header) do
    {
      'Accept' => '*/*',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization' => 'Bearer valid',
      'Content-Type' => 'application/x-www-form-urlencoded',
      'User-Agent' => 'Ruby'
    }
  end

  around do |example|
    original_management_url = ENV['MANAGEMENT_HOST']
    original_token = ENV['OWP_AUTH_TOKEN']
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    ENV['OWP_AUTH_TOKEN'] = 'valid'
    example.run
    ENV['MANAGEMENT_HOST'] = original_management_url
    ENV['OWP_AUTH_TOKEN'] = original_token
  end

  before do
    solr = Blacklight.default_index.connection
    solr.add([owp_work_with_approved_permission, owp_work_with_pending_permission, owp_work_with_denied_permission])
    solr.commit
  end

  context 'with a logged in user' do
    before do
      allow(User).to receive(:on_campus?).and_return(false)
      login_as user
    end
    context 'when there is a succesfull response from management' do
      before do
        stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
          .to_return(status: 200, body: '{
            "timestamp":"2023-11-02",
            "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
            "permission_set_terms_agreed":[1],
            "permissions":[{
              "oid":1718909,
              "permission_set":1,
              "permission_set_terms":1,
              "request_status":"Pending",
              "request_date":"2023-11-02T20:23:18.824Z",
              "access_until":null,
              "user_note": "lorem ipsum",
              "user_full_name": "Request Full Name"
            },
            {
              "oid":1618909,
              "permission_set":1,
              "permission_set_terms":1,
              "request_status":"Approved",
              "request_date":"2023-11-02T20:23:18.824Z",
              "access_until":"2034-11-02T20:23:18.824Z",
              "user_note":"Notepad",
              "user_full_name":"Handsome Dan"
            },
            {
              "oid":1818909,
              "permission_set":1,
              "permission_set_terms":1,
              "request_status":"Denied",
              "request_date":null,
              "access_until":null,
              "user_note":"loreem epsum",
              "user_full_name":"First Last"
            }]
          }')
        stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f3')
          .to_return(status: 200, body: '{
          "timestamp":"2023-11-02",
          "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f3"},
          "permission_set_terms_agreed":[1],
          "permissions":[]}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/terms")
          .to_return(status: 200, body: '{
        "id":1,
        "title":"Sample Title",
        "body":"lorem ipsum"
        }')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
          .to_return(status: 200, body: '{
          "id":1,
          "title":"Sample Title",
          "body":"lorem ipsum"
          }')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/terms")
          .to_return(status: 200, body: '{
        "id":1,
        "title":"Sample Title",
        "body":"lorem ipsum"
        }')
      end

      context 'who is an admin or approver' do
        before do
          logout user
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/mz5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"true" }')
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/mz5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"true" }')
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/mz5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"true" }')
          login_as admin_user
        end
        it 'a pending permission request will load the confirmation page' do
          visit 'catalog/1718909/request_confirmation'
          expect(page.body).to include 'Map of India'
          expect(page.body).not_to include 'Pending'
          expect(page.body).to include 'Access And Usage Rights'
          expect(page.body).to include 'uv-container'
        end
        it 'an approved permission request will load the confirmation page' do
          visit 'catalog/1618909/request_confirmation'
          expect(page.body).to include 'Map of China'
          expect(page.body).not_to include 'Approved'
          expect(page.body).to include 'Access And Usage Rights'
          expect(page.body).to include 'uv-container'
        end
        it 'a denied permission request will load the confirmation page' do
          visit 'catalog/1818909/request_confirmation'
          expect(page.body).to include 'Map of Australia'
          expect(page.body).not_to include 'Denied'
          expect(page.body).to include 'Access And Usage Rights'
          expect(page.body).to include 'uv-container'
        end
      end
      context 'who is not an admin or approver' do
        before do
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/my5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"false" }')
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/my5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"false" }')
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/my5679")
            .to_return(status: 200, body: '{ "is_admin_or_approver?":"false" }')
          login_as user
        end
        it 'a pending permission request will load the confirmation page' do
          visit 'catalog/1718909/request_confirmation'
          expect(page.body).to include 'Map of India'
          expect(page.body).to include 'Pending'
          expect(page.body).to include 'Request Full Name'
          expect(page.body).to include 'lorem ipsum'
          expect(page.body).to include 'CONTINUE'
        end
        it 'an approved permission request will load the confirmation page' do
          visit 'catalog/1618909/request_confirmation'
          expect(page.body).to include 'Map of China'
          expect(page.body).to include 'Approved'
          expect(page.body).to include 'Handsome Dan'
          expect(page.body).to include 'Notepad'
          expect(page.body).to include 'CONTINUE'
        end
        it 'a denied permission request will load the confirmation page' do
          visit 'catalog/1818909/request_confirmation'
          expect(page.body).to include 'Map of Australia'
          expect(page.body).to include 'Denied'
          expect(page.body).to include 'First Last'
          expect(page.body).to include 'loreem epsum'
          expect(page.body).to include 'CONTINUE'
        end
      end
    end

    context 'when there is not a succesfull response from management' do
      before do
        stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/terms")
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/my5679")
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/my5679")
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/terms")
          .to_return(status: 500, body: '{"title":"internal server error"}')
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/my5679")
          .to_return(status: 500, body: '{"title":"internal server error"}')
      end
      it 'any permission request will load the confirmation page with notice' do
        visit 'catalog/1618909/request_confirmation'
        expect(page.body).to include 'Map of China'
        expect(page.body).to include 'try again later'
        expect(page.body).to include 'Unavailable'
        visit 'catalog/1718909/request_confirmation'
        expect(page.body).to include 'Map of India'
        expect(page.body).to include 'try again later'
        expect(page.body).to include 'Unavailable'
        visit 'catalog/1818909/request_confirmation'
        expect(page.body).to include 'Map of Australia'
        expect(page.body).to include 'try again later'
        expect(page.body).to include 'Unavailable'
      end
    end
  end

  context 'without a logged in user' do
    it 'any permission request will redirect to the show page with link to request form' do
      visit 'catalog/1718909/request_confirmation'
      expect(page.body).to include 'Please log in to request access to these materials'
    end
  end
end
