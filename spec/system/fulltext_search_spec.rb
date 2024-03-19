# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fulltext search', type: :system, clean: true, js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:owp_user_no_access) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
  let(:owp_user_with_access) { FactoryBot.create(:user, netid: "net_id_2", sub: "27bd425ee-1093-40cd-ba0c-5a2355e37d6e2", uid: 'some_other_name', email: 'not_really@example.com') }
  let(:public_work) do
    {
      "id": "2034600",
      "title_tesim": ["[Map of China]. [public copy]"],
      "fulltext_tesim": ["This is the full text public"],
      "visibility_ssi": "Public"
    }
  end
  let(:child_work) do
    {
      "id": "998833",
      "parent_ssi": "2034600",
      "child_fulltext_wstsim": ["This is the full text public"]
    }
  end
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "fulltext_tesim": ["This is the full text Yale only"],
      "visibility_ssi": "Yale Community Only"
    }
  end
  let(:child_work_yale_only) do
    {
      "id": "998834",
      "parent_ssi": "1618909",
      "child_fulltext_wstsim": ["This is the full text Yale only"]
    }
  end
  let(:yale_owp_work) do
    {
      "id": "161890909",
      "title_tesim": ["[OwP Title]"],
      "fulltext_tesim": ["This is full text OwP"],
      "visibility_ssi": "Open with Permission"
    }
  end
  let(:child_work_owp) do
    {
      "id": "99883409",
      "parent_ssi": "161890909",
      "child_fulltext_wstsim": ["This is full text OwP"]
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
          "oid":161890909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":false,
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"}
        ]}',
                 headers: [])
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/27bd425ee-1093-40cd-ba0c-5a2355e37d6e2')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"27bd425ee-1093-40cd-ba0c-5a2355e37d6e2"},
        "permission_set_terms_agreed":[1],
        "permissions":[{
          "oid":161890909,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":true,
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"}
        ]}',
                 headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/161890909/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, child_work, child_work_yale_only, yale_owp_work, child_work_owp])
    solr.commit
  end

  context 'User with all permissions' do
    before do
      login_as user
    end

    it 'can view all full text search results' do
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).to have_content 'full text Yale only'
      expect(page).to have_content 'full text public'
    end
  end

  context 'User with some permissions' do
    before do
      allow(User).to receive(:on_campus?).and_return(true)
    end

    it 'can see some but not all full text search results' do
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).to have_content 'full text Yale only'
      expect(page).to have_content 'full text public'
    end
    it 'can see OwP full text when permission request is approved' do
      login_as owp_user_with_access
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).to have_content('Full Text:', count: 3)
      expect(page).to have_content 'full text OwP'
    end
  end

  context 'User with no permissions' do
    it 'cannot see OwP full text or full text label' do
      login_as owp_user_no_access
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).to have_content('Full Text:').twice
      expect(page).not_to have_content('Full Text:', count: 3)
      expect(page).not_to have_content 'full text OwP'
    end
    it 'cannot view YCO full text search results' do
      allow(User).to receive(:on_campus?).and_return(false)
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).not_to have_content 'full text Yale only'
      expect(page).to have_content 'full text public'
    end
  end
end
