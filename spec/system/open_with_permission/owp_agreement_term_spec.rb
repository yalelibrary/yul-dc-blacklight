# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Open with Permission", type: :system do
  let(:yale_user) { FactoryBot.create(:user, netid: "net_id1", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'user_uid', email: 'not_real@example.com') }
  let(:non_yale_user) { FactoryBot.create(:user, sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6g", uid: 'uid456', email: 'not_real_either@example.com') }
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
    original_blacklight_url = ENV['BLACKLIGHT_HOST']
    original_management_url = ENV['MANAGEMENT_HOST']
    original_token = ENV['OWP_AUTH_TOKEN']
    ENV['BLACKLIGHT_HOST'] = 'http://www.example.com'
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    ENV['OWP_AUTH_TOKEN'] = 'valid'
    example.run
    ENV['BLACKLIGHT_HOST'] = original_blacklight_url
    ENV['MANAGEMENT_HOST'] = original_management_url
    ENV['OWP_AUTH_TOKEN'] = original_token
  end
  before do
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[],
        "permissions":[]}').then.to_return(status: 200, body: '{
          "timestamp":"2023-11-02",
          "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
          "permission_set_terms_agreed":[1],
          "permissions":[]}')
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6g')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[],
        "permissions":[]}').then.to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6g"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}")
    solr = Blacklight.default_index.connection
    solr.add([owp_work_without_permission])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an authenticated user on the request form page' do
    before do
      stub_request(:post, 'http://www.example.com/management/agreement_term')
        .with(body: { "oid" => "1718909", "permission_set_terms_id" => "1", "user_email" => "not_real@example.com", "user_full_name" => "new", "user_netid" => "net_id1",
                      "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e" }, headers: valid_header)
        .to_return(status: 200)
      stub_request(:post, 'http://www.example.com/management/agreement_term')
        .with(body: { "oid" => "1718909", "permission_set_terms_id" => "1", "user_email" => "not_real_either@example.com", "user_full_name" => "new", "user_netid" => nil,
                      "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6g" }, headers: valid_header)
        .to_return(status: 200)
    end
    context 'with yale user' do
      it 'can display request form' do
        login_as yale_user
        visit "/catalog/1718909/request_form"
        expect(page.body).to include('These are some terms')
        click_on 'Agree'
        expect(page).to have_http_status(:success)
        expect(page.body).to include('SUBMIT')
      end
    end
    context 'with non yale user' do
      it 'can display request form' do
        login_as non_yale_user
        visit "/catalog/1718909/request_form"
        expect(page.body).to include('These are some terms')
        click_on 'Agree'
        expect(page).to have_http_status(:success)
        expect(page.body).to include('SUBMIT')
      end
    end
  end

  context 'as a not authenticated user on the request form page' do
    it 'redirects to the show page' do
      visit "/catalog/1718909/request_form"
      expect(page).to have_http_status(:success)
      expect(page.current_url).to eq('http://www.example.com/catalog/1718909')
      expect(page.body).to include('The material in this folder is open for research use only with permission.')
      expect(page.body).to include('Please log in')
    end
  end
end
