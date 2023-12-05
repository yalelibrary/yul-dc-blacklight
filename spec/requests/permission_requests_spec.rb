# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Permission Requests", type: :request, clean: true do
  let(:user) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
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

  around do |example|
    original_management_url = ENV['MANAGEMENT_HOST']
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    example.run
    ENV['MANAGEMENT_HOST'] = original_management_url
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
                 headers: [])
    stub_request(:post, 'http://www.example.com/management/api/permission_requests')
      .with(body: {
              "oid" => "1718909",
              "user_email" => "not_real@example.com",
              "user_full_name" => "Request Full Name",
              "user_netid" => "net_id",
              "user_note" => "lorem ipsum",
              "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e"
            },
            headers: {
              'Accept' => '*/*',
              'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Content-Type' => 'application/x-www-form-urlencoded',
              'User-Agent' => 'Ruby'
            })
      .to_return(status: 201, body: '{ "title": "New request created"}')
    stub_request(:post, 'http://www.example.com/catalog/1718909/request_form')
      .to_return(status: 201, body: '{ "title": "New request created"}')
    solr = Blacklight.default_index.connection
    solr.add([owp_work_with_permission, owp_work_without_permission])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
    sign_in user
  end

  context 'with an authenticated user' do
    it 'will create a new permission request and load confirmation page' do
      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': 'Request Full Name',
          'user_note': 'lorem ipsum'
        }
      }
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
    end
  end

  context 'with a NOT authenticated user' do
    it 'will redirect to the show page' do
      sign_out user
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
