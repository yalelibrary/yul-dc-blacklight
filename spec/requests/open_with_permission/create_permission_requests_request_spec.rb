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
      stub_request(:post, 'http://www.example.com/management/agreement_term')
        .with(body: { "oid" => "1718909", "permission_set_terms_id" => "1", "user_email" => "not_real@example.com", "user_full_name" => "new", "user_netid" => "net_id",
                      "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e" }, headers: valid_header)
        .to_return(status: 200)
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
    it 'can accept terms and redirect to request form' do
      post '/catalog/1718909/terms_and_conditions', params: {
        'oid': '1718909',
        'user_email': yale_user.email,
        'user_netid': yale_user.netid,
        'user_sub': yale_user.sub,
        'user_full_name': "new",
        'permission_set_terms_id': 1
      }, headers: valid_header
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
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
    it 'strips HTML/script tags from user_full_name and user_note before forwarding to management' do
      # Catch-all stub so the controller's POST always succeeds; we then
      # inspect the captured request body to assert what was actually sent.
      stub_request(:post, 'http://www.example.com/management/api/permission_requests')
        .to_return(status: 201, body: '{ "title": "New request created"}', headers: valid_header)

      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': '<script>alert("xss")</script>Request Full Name',
          'user_note': '<b>lorem</b> <img src=x onerror=alert(1)> ipsum'
        }
      }, headers: valid_header

      management_post = a_request(:post, 'http://www.example.com/management/api/permission_requests')

      # Positive: management receives only the cleaned plain-text values.
      # `<script>` element contents are removed by the full
      # sanitizer; inline tags like `<b>` and `<img>` are stripped, leaving
      # their surrounding text.
      # rubocop:disable Layout/LineLength
      expect(management_post.with(body: 'oid=1718909&user_email=not_real%40example.com&user_full_name=alert%28%22xss%22%29Request+Full+Name&user_netid=net_id&user_note=lorem++ipsum&user_sub=7bd425ee-1093-40cd-ba0c-5a2355e37d6e')).to have_been_made
      # rubocop:enable Layout/LineLength
      # No HTML markup or script payload reaches management,
      # regardless of which field it was injected into.
      expect(management_post.with(body: /<\s*script/i)).not_to have_been_made
      expect(management_post.with(body: /<\s*img/i)).not_to have_been_made
      expect(management_post.with(body: /<\s*b\s*>/i)).not_to have_been_made
      expect(management_post.with(body: /onerror/i)).not_to have_been_made
      expect(management_post.with(body: /alert\(/i)).not_to have_been_made

      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
    end
  end

  context 'with an authenticated non yale user' do
    before do
      sign_in non_yale_user
      stub_request(:post, 'http://www.example.com/management/agreement_term')
        .with(body: { "oid" => "1718909", "permission_set_terms_id" => "1", "user_email" => "not_real_either@example.com", "user_full_name" => "new", "user_netid" => nil,
                      "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6f" }, headers: valid_header)
        .to_return(status: 200)
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
    it 'can accept terms and redirect to request form' do
      post '/catalog/1718909/terms_and_conditions', params: {
        'oid': '1718909',
        'user_email': non_yale_user.email,
        'user_netid': non_yale_user.netid,
        'user_sub': non_yale_user.sub,
        'user_full_name': "new",
        'permission_set_terms_id': 1
      }, headers: valid_header
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
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
    it 'will not accept terms and will redirect to show page' do
      post '/catalog/1718909/terms_and_conditions'
      expect(response).to have_http_status(:redirect)
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909')
    end
    it 'sending request form will redirect to the show page not confirmation page' do
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

  context 'when management returns a failure response to a permission request' do
    before { sign_in yale_user }

    def stub_permission_request(status:, body: '')
      stub_request(:post, 'http://www.example.com/management/api/permission_requests')
        .to_return(status: status, body: body, headers: valid_header)
    end

    def submit_request_form
      post '/catalog/1718909/request_form', params: {
        'oid': '1718909',
        'permission_request': {
          'user_full_name': 'Request Full Name',
          'user_note': 'lorem ipsum'
        }
      }, headers: valid_header
    end

    it 'redirects to the request form with "Object not found" on Invalid Parent OID' do
      stub_permission_request(status: 400, body: 'Invalid Parent OID')
      submit_request_form
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
      expect(flash[:notice]).to eq('Object not found')
    end

    it 'redirects to the request form echoing the body when the object is private' do
      stub_permission_request(status: 400, body: 'Object is private')
      submit_request_form
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
      expect(flash[:notice]).to eq('Object is private')
    end

    it 'redirects to the request form with a too-many-requests notice on 403' do
      stub_permission_request(status: 403)
      submit_request_form
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
      expect(flash[:notice]).to eq('Too many pending requests')
    end

    it 'renders unauthorized JSON on 401' do
      stub_permission_request(status: 401)
      submit_request_form
      expect(response).to have_http_status(:unauthorized)
    end

    it 'redirects to the request form with a generic error on an unexpected status' do
      stub_permission_request(status: 500)
      submit_request_form
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_form')
      expect(flash[:notice]).to eq('An error has occured.  Please try again later.')
    end
  end

  context 'when management returns a failure response to an agreement term' do
    before { sign_in yale_user }

    def stub_agreement_term(status:, body: '')
      stub_request(:post, 'http://www.example.com/management/agreement_term')
        .to_return(status: status, body: body, headers: valid_header)
    end

    def submit_terms
      post '/catalog/1718909/terms_and_conditions', params: {
        'oid': '1718909',
        'user_email': yale_user.email,
        'user_netid': yale_user.netid,
        'user_sub': yale_user.sub,
        'user_full_name': "new",
        'permission_set_terms_id': 1
      }, headers: valid_header
    end

    it 'redirects to the catalog page echoing the body when the term is not found' do
      stub_agreement_term(status: 400, body: 'Term not found.')
      submit_terms
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909')
      expect(flash[:notice]).to eq('Term not found.')
    end

    it 'redirects to the catalog page echoing the body when the user is not found' do
      stub_agreement_term(status: 400, body: 'User not found.')
      submit_terms
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909')
      expect(flash[:notice]).to eq('User not found.')
    end

    it 'renders unauthorized JSON on 401' do
      stub_agreement_term(status: 401)
      submit_terms
      expect(response).to have_http_status(:unauthorized)
    end

    it 'redirects to the catalog page with a generic error on an unexpected status' do
      stub_agreement_term(status: 500)
      submit_terms
      expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909')
      expect(flash[:notice]).to eq('An error has occured.  Please try again later.')
    end
  end
end
