# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Open with Permission", type: :system do
  let(:user) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
  let(:owp_work_six_with_approved_permission) do
    {
      "id": "1618909",
      "title_tesim": ["Map of China"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["111111"],
      "callNumber_tesim": ['1234567890']
    }
  end
  let(:owp_work_seven_with_denied_permission) do
    {
      "id": "1718909",
      "title_tesim": ["Map of India"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["222222"],
      "callNumber_tesim": ['1234567891']
    }
  end
  let(:owp_work_eight_with_pending_permission) do
    {
      "id": "1818909",
      "title_tesim": ["Map of Laos"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["333333"],
      "callNumber_tesim": ['1234567892']
    }
  end
  let(:owp_work_nine_with_approved_permission) do
    {
      "id": "1918909",
      "title_tesim": ["Map of Thailand"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["444444"],
      "callNumber_tesim": ['1234567893']
    }
  end
  let(:owp_work_ten_with_denied_permission) do
    {
      "id": "11018909",
      "title_tesim": ["Map of New Zealand"],
      "visibility_ssi": "Open with Permission",
      "child_oids_ssim": ["555555"],
      "callNumber_tesim": ['1234567894']
    }
  end

  around do |example|
    original_management_url = ENV['MANAGEMENT_HOST']
    original_blacklight_url = ENV['BLACKLIGHT_HOST']
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    ENV['BLACKLIGHT_HOST'] = 'http://www.example.com/'
    example.run
    ENV['MANAGEMENT_HOST'] = original_management_url
    ENV['BLACKLIGHT_HOST'] = original_blacklight_url
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
            "request_status":"Denied",
            "request_date":"2024-11-02T20:23:18.824Z",
            "access_until":null
          },
          {
            "oid":1818909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":"Pending",
            "request_date":"2025-11-02T20:23:18.824Z",
            "access_until":null
          },
          {
            "oid":1918909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":"Approved",
            "request_date":"2026-11-02T20:23:18.824Z",
            "access_until":"2034-11-02T20:23:18.824Z"
          },
          {
            "oid":11018909,
            "permission_set":1,
            "permission_set_terms":1,
            "request_status":"Denied",
            "request_date":"2027-11-02T20:23:18.824Z",
            "access_until":null
          }
        ]}',
                 headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1618909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1718909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    stub_request(:get, "http://www.example.com/management/api/permission_sets/1918909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    stub_request(:get, "http://www.example.com/management/api/permission_sets/11018909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    solr = Blacklight.default_index.connection
    solr.add([
               owp_work_six_with_approved_permission,
               owp_work_seven_with_denied_permission,
               owp_work_eight_with_pending_permission,
               owp_work_nine_with_approved_permission,
               owp_work_ten_with_denied_permission
             ])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(false)
  end

  context 'as an authenticated user on the requests page' do
    context 'with correct permission' do
      before do
        login_as user
        visit '/permission_requests'
      end

      it 'can display as expected' do
        expect(page).to have_http_status(:success)
        # Header is present
        expect(page).to have_content 'Digital Access Requests'
        # table has 5 columns: title, call number, request date, status, access expires
        expect(page).to have_content 'Title'
        expect(page).to have_content 'Call Number'
        expect(page).to have_content 'Request Date'
        expect(page).to have_content 'Status'
        expect(page).to have_content 'Access Expires'
        # has icons for sorting columns and they work
        expect(page).to have_css '.double-arrow'
        # title column displays owp object's title as a link
        expect(page).to have_link 'Map of New Zealand', href: '/catalog/11018909'
        # call number column displays owp object's call number
        expect(page).to have_content '1234567890'
        # request date column displays request date
        expect(page).to have_content '11/02/27'
        # status column displays request status
        # status column displays Pending, Approved or Denied
        expect(page).to have_content('Pending').once
        expect(page).to have_content('Approved').twice
        expect(page).to have_content('Denied').twice
        # access expires column displays access until
        # access expires column displays N/A for Pending or Denied requests
        expect(page).to have_content('N/A', count: 3)
        expect(page).to have_content('11/02/34').twice
        # has a button that goes to /bookmarks
        expect(page).to have_link 'BACK TO BOOKMARKS', href: bookmarks_path
      end

      it 'can search as expected' do
        click_on 'Search'
        expect(page.current_url).to eq 'http://web.library.yale.edu/gsearch'
      end
    end
  end

  context 'as a NOT authenticated user on the requests page' do
    it 'will redirect to homepage' do
      logout user
      visit '/permission_requests'
      expect(page.current_url).to eq ENV['BLACKLIGHT_HOST']
    end
  end
end
