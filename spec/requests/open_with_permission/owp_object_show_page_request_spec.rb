# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Open with Permission", type: :request, clean: true do
  let(:user) { FactoryBot.create(:user, netid: "net_id1", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'user_uid', email: 'not_real@example.com') }
  let(:non_yale_user) { FactoryBot.create(:user, sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6g", uid: 'uid456', email: 'not_real_either@example.com') }
  let(:admin_approver_user) { FactoryBot.create(:user, netid: "net_id2", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6d", uid: 'unique_uid', email: 'not_real@example.com') }
  let(:non_approved_user) { FactoryBot.create(:user, netid: "net_id3", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6f", uid: 'some_name', email: 'not_real@example.com') }
  let(:owp_work_with_permission) do
    {
      "id": "1618909",
      "title_tesim": ["Map of China"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["11111"]
    }
  end
  let(:owp_work_without_permission) do
    {
      "id": "1718909",
      "title_tesim": ["Map of India"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["222222"]
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
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[1],
        "permissions":[{
          "oid":1618909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"},
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":null,
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":null
          }
        ]}',
                 headers: valid_header)
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6g')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6g"},
        "permission_set_terms_agreed":[1],
        "permissions":[{
          "oid":1618909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"},
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":null,
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":null
          }
        ]}',
                 headers: valid_header)
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/#{user.netid}")
      .to_return(status: 200, body: '{
        "is_admin_or_approver?":"true"
        }',
                 headers: valid_header)
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/#{admin_approver_user.netid}")
      .to_return(status: 200, body: '{
        "is_admin_or_approver?":"true"
        }',
                 headers: valid_header)
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/#{non_approved_user.netid}")
      .to_return(status: 200, body: '{
        "is_admin_or_approver?":"false"
        }',
                 headers: valid_header)
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6d')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6d"},
        "permission_set_terms_agreed":[],
        "permissions":[
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":"Denied",
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":"2034-11-02T20:23:18.824Z"
          }
        ]}',
                 headers: [])
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f"},
        "permission_set_terms_agreed":[],
        "permissions":[
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":"Pending",
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":"2034-11-02T20:23:18.824Z"
          }
        ]}',
                 headers: valid_header)
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: valid_header)
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: valid_header)
    solr = Blacklight.default_index.connection
    solr.add([owp_work_with_permission, owp_work_without_permission])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an authenticated user on the show page' do
    context 'with correct permission' do
      it 'can display uv, metadata, and tools' do
        sign_in user
        get "/catalog/1618909"
        expect(response).to have_http_status(:success)
        expect(response.body).to include('universal-viewer-iframe')
        expect(response.body).to include('Access And Usage Rights')
        expect(response.body).to include('Manifest Link')
      end
    end
    context 'with permission set admin/approver user' do
      it 'can display uv, metadata, and tools' do
        sign_in admin_approver_user
        get "/catalog/1618909"
        expect(response).to have_http_status(:success)
        expect(response.body).to include('universal-viewer-iframe')
        expect(response.body).to include('Access And Usage Rights')
        expect(response.body).to include('Manifest Link')
      end
    end
    context 'with incorrect permission' do
      it 'does not display uv and most tools but does display metadata' do
        get "/catalog/1718909"
        expect(response).to have_http_status(:success)
        expect(response.body).not_to include('universal-viewer-iframe')
        expect(response.body).to include('Access And Usage Rights')
        # this is part of the alt tag for the tool links when they are disabled
        expect(response.body).to include('The digital version of this work is restricted')
      end
    end
    context 'with pending request' do
      it 'displays pending request notification' do
        sign_in non_approved_user
        get "/catalog/1718909"
        expect(response).to have_http_status(:success)
        expect(response.body).not_to include('universal-viewer-iframe')
        expect(response.body).to include('Access And Usage Rights')
        # rubocop:disable Layout/LineLength
        expect(response.body).to include('Your request to access this item has been received. Thank you for your patience as your request is considered. You will be notified via email of the results of your request once a decision has been made.')
        # rubocop:enable Layout/LineLength
      end
    end
  end

  context 'as an authenticated user on the request form page' do
    it 'displays metadata, username, email, input fields, and buttons if user has accepted the terms and conditions' do
      sign_in user
      get "/catalog/1718909/request_form"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Map of India')
      expect(response.body).to include(user.uid.to_s)
      expect(response.body).to include(user.email.to_s)
      expect(response.body).to include('input required="required" type="text" name="permission_request[user_full_name]" id="permission_request_user_full_name"')
      expect(response.body).to include('textarea rows="3" required="required" name="permission_request[user_note]" id="permission_request_user_note"')
      expect(response.body).to include('CANCEL')
      expect(response.body).to include('SUBMIT REQUEST')
    end
  end

  context 'as an authenticated non yale user on the request form page' do
    it 'displays metadata, username, email, input fields, and buttons if user has accepted the terms and conditions' do
      sign_in non_yale_user
      get "/catalog/1718909/request_form"
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Map of India')
      expect(response.body).to include(non_yale_user.uid.to_s)
      expect(response.body).to include(non_yale_user.email.to_s)
      expect(response.body).to include('input required="required" type="text" name="permission_request[user_full_name]" id="permission_request_user_full_name"')
      expect(response.body).to include('textarea rows="3" required="required" name="permission_request[user_note]" id="permission_request_user_note"')
      expect(response.body).to include('CANCEL')
      expect(response.body).to include('SUBMIT REQUEST')
    end
  end

  it 'displays the terms and conditions page if user has not accepted the terms' do
    sign_in non_approved_user
    get "/catalog/1718909/request_form"
    expect(response.body).to include('You must accept the following terms and conditions in order to proceed.')
  end

  context 'as a not authenticated user on the request form page' do
    it 'redirects to the show page' do
      sign_out user
      get "/catalog/1718909/request_form"
      expect(response).to have_http_status(:redirect)
    end
  end
end
