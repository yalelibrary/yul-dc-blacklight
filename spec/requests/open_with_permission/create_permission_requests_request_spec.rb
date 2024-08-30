# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Permission Requests", type: :request, clean: true do
  let(:user) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
  let(:admin_user) { FactoryBot.create(:user, netid: "netty_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6f", uid: 'some_other_name', email: 'not_real_either@example.com') }
  let(:private_work) do
    {
      "id": "1518909",
      "title_tesim": ["Map of Australia"],
      "visibility_ssi": "Private",
      "child_oids_ssim": ["333333"]
    }
  end
  let(:unreal_work) do
    {
      "id": "1418909",
      "title_tesim": ["Map of Atlantis"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["4444444"]
    }
  end
  let(:public_work) do
    {
      "id": "1618909",
      "title_tesim": ["Map of China"],
      "visibility_ssi": "Public",
      "child_oids_ssim": ["11111"]
    }
  end
  let(:owp_work) do
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
    solr = Blacklight.default_index.connection
    solr.add([private_work, public_work, owp_work, unreal_work])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  describe 'an authenticated user' do
    context 'with a successful response from management' do
      before do
        stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
          .to_return(status: 200, body: '{
          "id":1,
          "title":"Sample Title",
          "body":"lorem ipsum"
          }')  
      end

      context 'who is not an admin or approver' do
        before do
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/mz5679")
          .to_return(status: 200, body: '{ "is_admin_or_approver?":"false" }')
          sign_in user
        end
        context 'who has agreed to terms' do
          context 'who has not submitted a request for that object' do
            it 'will create a new permission request and redirect to the confirmation page' do
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
                .to_return(status: 201, body: '{ "title": "New request created"}')
  
              stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
                .to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
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
          context 'who has already submitted a request for that object' do
            it 'will not create a new permission request and redirect to the show page' do
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
                    "request_date":null,
                    "access_until":null,
                    "user_note": "permission.user_note",
                    "user_full_name": "request_user.name"}]}')
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
                .to_return(status: 403, body: '{ "title": "Too many pending requests for object"}')
              post '/catalog/1718909/request_form', params: {
                'oid': '1718909',
                'permission_request': {
                  'user_full_name': 'Request Full Name',
                  'user_note': 'lorem ipsum'
                }
              }, headers: valid_header
              # byebug
              expect(response).to have_http_status(:redirect)

              expect(response.body).to include('check access page')
            end
          end
          context 'who has already submitted too many requests for that permission set' do
            before do
              stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
                .to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
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
                .to_return(status: 403, body: '{ "title": "Too many pending requests for set" }')
            end
            it 'will not create a new permission request and will notify user' do
              post '/catalog/1718909/request_form', params: {
                'oid': '1718909',
                'permission_request': {
                  'user_full_name': 'Request Full Name',
                  'user_note': 'lorem ipsum'
                }
              }, headers: valid_header
              expect(response.body).to include('Too many pending requests')
            end
          end
          context 'who has submitted a request for a public parent' do
            before do
              stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
                .to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
              stub_request(:post, 'http://www.example.com/management/api/permission_requests')
                .with(body: {
                        "oid" => "1618909",
                        "user_email" => "not_real@example.com",
                        "user_full_name" => "Request Full Name",
                        "user_netid" => "net_id",
                        "user_note" => "lorem ipsum",
                        "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e"
                      },
                      headers: valid_header)
                .to_return(status: 400, body: '{ "title": "Object is public, permission not required" }')
            end
            it 'will not create a new permission request and will notify user' do
              post '/catalog/1618909/request_form', params: {
                'oid': '1618909',
                'permission_request': {
                  'user_full_name': 'Request Full Name',
                  'user_note': 'lorem ipsum'
                }
              }, headers: valid_header
              expect(response.body).to include('Object is public, permission not required')
            end
          end
          context 'who has submitted a request for a private parent' do
            before do
              stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
                .to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
              stub_request(:post, 'http://www.example.com/management/api/permission_requests')
                .with(body: {
                        "oid" => "1518909",
                        "user_email" => "not_real@example.com",
                        "user_full_name" => "Request Full Name",
                        "user_netid" => "net_id",
                        "user_note" => "lorem ipsum",
                        "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e"
                      },
                      headers: valid_header)
                .to_return(status: 400, body: '{ "title": "Object is private" }')
            end
            it 'will not create a new permission request and will notify user' do
              post '/catalog/1518909/request_form', params: {
                'oid': '1518909',
                'permission_request': {
                  'user_full_name': 'Request Full Name',
                  'user_note': 'lorem ipsum'
                }
              }, headers: valid_header
              expect(response.body).to include('Object is private')
            end
          end
          context 'who has submitted a request for a parent that does not exist in management' do
            before do
              stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
                .to_return(status: 200, body: '{
                  "timestamp":"2023-11-02",
                  "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                  "permission_set_terms_agreed":[1],
                  "permissions":[]}')
              stub_request(:post, 'http://www.example.com/management/api/permission_requests')
                .with(body: {
                        "oid" => "1418909",
                        "user_email" => "not_real@example.com",
                        "user_full_name" => "Request Full Name",
                        "user_netid" => "net_id",
                        "user_note" => "lorem ipsum",
                        "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6e"
                      },
                      headers: valid_header)
                .to_return(status: 400, body: '{ "title": "Invalid Parent OID" }')
            end
            it 'will not create a new permission request and will notify user' do
              post '/catalog/1418909/request_form', params: {
                'oid': '1418909',
                'permission_request': {
                  'user_full_name': 'Request Full Name',
                  'user_note': 'lorem ipsum'
                }
              }, headers: valid_header
              expect(response.body).to include('Object not found')
            end
          end
        end
        context 'who has not agreed to terms' do
          before do
            stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
              .to_return(status: 200, body: '{
                "timestamp":"2023-11-02",
                "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
                "permission_set_terms_agreed":[],
                "permissions":[]}')
          end
          it 'will not create a new permission request and will redirect to the terms page' do
            post '/catalog/1718909/request_form', params: {
              'oid': '1718909',
              'permission_request': {
                'user_full_name': 'Request Full Name',
                'user_note': 'lorem ipsum'
              }
            }, headers: valid_header
            expect(response.body).to include('Sample Title')
          end
        end
      end

      context 'who is an admin or approver' do
        before do
          stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/my5679")
          .to_return(status: 200, body: '{ "is_admin_or_approver?":"true" }')
          stub_request(:post, 'http://www.example.com/management/api/permission_requests')
          .with(body: {
                  "oid" => "1718909",
                  "user_email" => "not_real@example.com",
                  "user_full_name" => "Request Full Name",
                  "user_netid" => "netty_id",
                  "user_note" => "lorem ipsum",
                  "user_sub" => "7bd425ee-1093-40cd-ba0c-5a2355e37d6f"
                },
                headers: valid_header)
          .to_return(status: 400, body: '{ "title": "User is admin or approver"}')
        stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f')
          .to_return(status: 200, body: '{
            "timestamp":"2023-11-02",
            "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f"},
            "permission_set_terms_agreed":[],
            "permissions":[]}')
          sign_in admin_user
        end
        it 'will create a new permission request and redirect to the confirmation page' do
          post '/catalog/1718909/request_form', params: {
            'oid': '1718909',
            'permission_request': {
              'user_full_name': 'Request Full Name',
              'user_note': 'lorem ipsum'
            }
          }, headers: valid_header
          expect(response.body).to include('You have permission to view this object as an administrator or approver')
        end
      end

      # when management is has 300 or 500 status
      context 'with an unsuccessful response from management' do
        it 'in 500 range will not create a new permission request and will notify the user' do
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
            .to_return(status: 500)
  
          stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
            .to_return(status: 500)
          post '/catalog/1718909/request_form', params: {
            'oid': '1718909',
            'permission_request': {
              'user_full_name': 'Request Full Name',
              'user_note': 'lorem ipsum'
            }
          }, headers: valid_header
          expect(response.body).to include('try again later')
          # expect(response).to have_http_status(:redirect)
          # expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
        end
        it 'will not create a new permission request and will notify the user' do
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
            .to_return(status: 300)
  
          stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
            .to_return(status: 300)
          post '/catalog/1718909/request_form', params: {
            'oid': '1718909',
            'permission_request': {
              'user_full_name': 'Request Full Name',
              'user_note': 'lorem ipsum'
            }
          }, headers: valid_header
          expect(response.body).to include('try again later')
          # expect(response).to have_http_status(:redirect)
          # expect(response.redirect_url).to eq('http://www.example.com/catalog/1718909/request_confirmation')
        end
      end
    end
  end

  describe 'a NOT authenticated user' do
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
