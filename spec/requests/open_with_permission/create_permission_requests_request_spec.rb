# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Permission Requests", type: :request, clean: true do
  let(:yale_user) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
  let(:non_yale_user) { FactoryBot.create(:user, sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6f", uid: 'som456', email: 'not_real_either@example.com') }
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
      'Content-Type' => 'application/x-www-form-urlencoded',
      'User-Agent' => 'Ruby',
      'Authorization' => "Bearer valid"
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
        "permission_set_terms_agreed":[],
        "permissions":[{
          "oid":1618909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z",
          "user_note": "permission.user_note",
          "user_full_name": "request_user.name"},
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":null,
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":null,
            "user_note": "lorem ipsum",
            "user_full_name": "Request Full Name"}
        ]}',
                 headers: valid_header)
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f"},
        "permission_set_terms_agreed":[],
        "permissions":[{
          "oid":1618909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":"Approved",
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z",
          "user_note": "permission.user_note",
          "user_full_name": "request_user.name"},
          {
            "oid":1718909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":null,
            "request_date":"2023-11-02T20:23:18.824Z",
            "access_until":null,
            "user_note": "lorem ipsum",
            "user_full_name": "Request Full Name"}
        ]}',
                 headers: valid_header)
    solr = Blacklight.default_index.connection
    solr.add([owp_work_with_permission, owp_work_without_permission])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'with an authenticated yale user' do
    before do
      sign_in yale_user
      stub_request(:post, 'http://www.example.com/management/api/permission_requests')
        .with(body: {
                "oid" => "1718909",
                "user_email" => "not_real@example.com",
                "user_full_name" => "Request Full Name",
                "user_netid" => "net_id",
                "user_note" => "lorem ipsum",
                "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e"
              },
              headers: valid_header)
        .to_return(status: 201, body: '{ "title": "New request created"}', headers: valid_header)
    end
    it 'will create a new permission request and redirect to the confirmation page' do
      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': 'Request Full Name',
          'user_note': 'lorem ipsum'
        }
      }, headers: valid_header
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
    end
  end

  context 'with an authenticated non yale user' do
    before do
      sign_in non_yale_user
      stub_request(:post, 'http://www.example.com/management/api/permission_requests')
        .with(body: {
                "oid" => "1718909",
                "user_email" => "not_real_either@example.com",
                "user_full_name" => "Request Full Name",
                "user_netid" => nil,
                "user_note" => "lorem ipsum",
                "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6f"
              },
              headers: valid_header)
        .to_return(status: 201, body: '{ "title": "New request created"}', headers: valid_header)
    end
    it 'will create a new permission request and redirect to the confirmation page' do
      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': 'Request Full Name',
          'user_note': 'lorem ipsum'
        }
      }, headers: valid_header
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
    end
  end

  context 'with a NOT authenticated user' do
    it 'will redirect to the show page' do
      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': 'Request Full Name',
          'user_note': 'lorem ipsum'
        }
      }
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909')
    end
  end
end
