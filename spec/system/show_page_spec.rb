# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Show Page', type: :system, js: true, clean: true do
  let(:user) { FactoryBot.create(:user) }
  let(:request_user) { FactoryBot.create(:user, netid: "net_id", sub: "7bd425ee-1093-40cd-ba0c-5a2355e37d6e", uid: 'some_name', email: 'not_real@example.com') }
  let(:thumbnail_size_in_opengraph) { "!1200,630" }
  let(:thumbnail_size_in_solr) { "!200,200" }

  around do |example|
    original_download_bucket = ENV['S3_DOWNLOAD_BUCKET_NAME']
    original_management_url = ENV['MANAGEMENT_HOST']
    ENV['S3_DOWNLOAD_BUCKET_NAME'] = 'yul-test-samples'
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    example.run
    ENV['S3_DOWNLOAD_BUCKET_NAME'] = original_download_bucket
    ENV['MANAGEMENT_HOST'] = original_management_url
  end
  # rubocop:disable Layout/LineLength
  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/111.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/112.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/113.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/22/22/222.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/12/11/112.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/45/12/34/12345.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/123')
      .to_return(status: 200, body: '{"timestamp":"2023-11-02","user":{"sub":"123"},"permission_set_terms_agreed":[],"permissions":[{"oid":12345,"permission_set":1,"permission_set_terms":1,"request_status":true,"request_date":"2023-11-02T20:23:18.824Z","access_until":"2024-11-02T20:23:18.824Z"}]}', headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/12345/#{user.uid}")
      .to_return(status: 200, body: '{
        "is_admin_or_approver?":"false"
        }',
                 headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/54321/#{user.uid}")
      .to_return(status: 200, body: '{
        "is_admin_or_approver?":"false"
        }',
                 headers: [])
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[],
        "permissions":[{
          "oid":12345,
          "permission_set":1,
          "permission_set_terms":1,
          "request_status":true,
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"}
        ]}',
                 headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/12345/terms")
      .to_return(status: 200, body: "{\"id\":1,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})
    stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
      .to_return(status: 200, body: '{
        "timestamp":"2023-11-02",
        "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
        "permission_set_terms_agreed":[2],
        "permissions":[{
          "oid":54321,
          "permission_set":1,
          "permission_set_terms":2,
          "request_status":true,
          "request_date":"2023-11-02T20:23:18.824Z",
          "access_until":"2034-11-02T20:23:18.824Z"}
        ]}',
                 headers: [])
    stub_request(:get, "http://www.example.com/management/api/permission_sets/54321/terms")
      .to_return(status: 200, body: "{\"id\":2,\"title\":\"Permission Set Terms\",\"body\":\"These are some terms\"}", headers: {})

    solr = Blacklight.default_index.connection
    solr.add([llama,
              llama_child_1,
              llama_child_2,
              dog,
              eagle,
              puppy,
              owp_work,
              owp_work_2,
              train,
              void])
    solr.commit
  end
  # rubocop:enable Layout/LineLength

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      ancestorTitles_tesim: ['Level0', 'Level1', 'Level2', 'Level3', 'Oversize', 'Abraham Lincoln collection (GEN MSS 257)', 'Beinecke Rare Book and Manuscript Library (BRBL)'],
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      creator_tesim: ['Anna Elizabeth Dewdney'],
      child_oids_ssim: [112, 113],
      oid_ssi: 111,
      thumbnail_path_ss: "https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_solr}/0/default.jpg",
      callNumber_ssim: "call number",
      has_fulltext_ssi: 'Yes',
      series_ssi: "Series 1: Oversize"
    }
  end

  let(:owp_work) do
    {
      id: '12345',
      title_tesim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Open with Permission',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Paulo Coelho']
    }
  end

  let(:owp_work_2) do
    {
      id: '54321',
      title_tesim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Open with Permission',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Paulo Coelho']
    }
  end

  let(:llama_child_1) do
    {
      id: '112',
      title_tesim: ['Baby Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney'],
      fulltext_tesim: ['fulltext text for llama child one.'],
      has_fulltext_ssi: 'Partial'
    }
  end

  let(:llama_child_2) do
    {
      id: '113',
      title_tesim: ['Baby Llama 2: The Sequel'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney']
    }
  end

  let(:dog) do
    {
      id: '222',
      title_tesim: ['HandsomeDan Bulldog'],
      format: 'three dimensional object',
      language_ssim: 'en',
      visibility_ssi: 'Public',
      genre_ssim: 'Artifacts',
      resourceType_ssim: 'Books, Journals & Pamphlets',
      has_fulltext_ssi: 'No',
      creator_ssim: ['Andy Graves']
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_tesim: ['Aquila Eccellenza'],
      format: 'still image',
      language_ssim: 'it',
      visibility_ssi: 'Public',
      genre_ssim: 'Manuscripts',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Andrew Norriss']
    }
  end

  let(:puppy) do
    {
      id: '444',
      title_tesim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Public',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['Paulo Coelho']
    }
  end

  let(:train) do
    {
      id: '555',
      title_tesim: ['The Boiler Makers'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Yale Community Only',
      genre_ssim: 'Animation',
      resourceType_ssim: 'Archives or Manuscripts',
      creator_ssim: ['France A. Cordova'],
      oid_ssi: 555,
      thumbnail_path_ss: "https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_solr}/0/default.jpg"
    }
  end

  let(:void) do
    {
      other_vis_bsi: true,
      id: '666'
    }
  end

  it 'has expected css' do
    visit '/catalog?search_field=all_fields&q='
    click_on 'Amor Llama', match: :first
    expect(page).to have_css '.btn-show'
    expect(page).to have_css '.constraints-container'
    expect(page).to have_css '.show-buttons'
    expect(page).to have_css '.manifestItem'
  end

  context '"Back to Search Results" button' do
    it 'returns user to search results' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      expect(page).to have_button("Back to Search Results")
      expect(page).to have_xpath("//button[@href='/catalog?page=1&per_page=10&search_field=all_fields']")
    end
  end

  context 'Archival Context breadcrumbs' do
    it 'renders the Archival Context' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      expect(page).to have_content 'Found In:'
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > ... >'
      click_on("...")
      expect(page).to have_content 'Beinecke Rare Book and Manuscript Library (BRBL) > Abraham Lincoln collection (GEN MSS 257) > Series 1: Oversize > Level3 > Level2 > Level1 > Level0'
    end
  end

  context '"New Search" button' do
    it 'returns user to homepage' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      expect(page).to have_button "New Search"
      expect(page).to have_xpath("//button[@href='/catalog']")
      expect(page.first('button.catalog_startOverLink').text).to eq('NEW SEARCH').or eq('New Search')
    end
  end

  context 'Universal Viewer' do
    it 'does not have a .json extension in the src attribute' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      src = find('.universal-viewer-iframe')['src']
      expect(src).not_to include('.json')
    end

    context 'sending child oid as a parameter' do
      # TODO: re-enable test when result is consistent
      xit 'uses child\'s page when oid is valid' do
        visit 'catalog/111?image_id=113'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to include '&cv=1'
      end
      it 'uses first page when oid is invalid' do
        visit 'catalog/111?image_id=11312321'
        src = find('.universal-viewer-iframe')['src']
        expect(src).to include '&cv=0'
      end
    end

    context 'without full text available' do
      it 'does not have a full text button' do
        visit 'catalog/222'

        expect(page).not_to have_content('Show Full Text')
      end
    end

    context 'with full text available' do
      it 'has a "Show Full Text" button' do
        visit 'catalog/111'

        expect(page).to have_css('.fulltext-button')
        expect(page).to have_content('Show Full Text')
      end
      it 'has a "Show Full Text" button with a partial fulltext status' do
        visit 'catalog/112'

        expect(page).to have_css('.fulltext-button')
        expect(page).to have_content('Show Full Text')
      end
    end
  end

  context 'with public works' do
    it 'Metadata og tags are in the header of html' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      expect(page.html).to include("og:title")
      expect(page.html).to include("Amor Llama")
      expect(page.html).to include("og:url")
      expect(page.html).to include("https://collections.library.yale.edu/catalog/111")
      expect(page.html).to include("og:type")
      expect(page.html).to include("website")
      expect(page.html).to include("og:description")
      expect(page.html).to include("Anna Elizabeth Dewdney")
      expect(page.html).to include("og:image")
      expect(page.html).to include("https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg")
      expect(page.html).to include("og:image:type")
      expect(page.html).to include("image/jpeg")
    end
    it 'has og namespace' do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Amor Llama', match: :first
      expect(page).to have_css("html[prefix='og: https://ogp.me/ns#']", visible: false)
    end
  end

  context 'with yale-only works' do
    before do
      visit 'catalog/555'
    end
    # TODO: re-enable test when result is consistent
    xit 'does not have image of og tag' do
      expect(page).not_to have_css("meta[property='og:image'][content='https://this_is_a_iiif_image/iiif/2/17120080/full/#{thumbnail_size_in_opengraph}/0/default.jpg']", visible: false)
      expect(page).not_to have_css("meta[property='og:image:type'][content='image/jpeg']", visible: false)
    end
  end

  context "Metadata block" do
    # TODO: re-enable test when result is consistent
    xit 'is not displayed when empty', :use_other_vis do
      visit 'catalog/666'

      expect(page).not_to have_content "Description", count: 2
      expect(page).not_to have_content "Collection Information"
      expect(page).not_to have_content "Subjects, Formats, And Genres"
      expect(page).not_to have_content "Access And Usage Rights"
      expect(page).not_to have_content "Identifiers"
    end
    it 'is displayed when they have values' do
      visit 'catalog/111'

      expect(page).to have_content "Description", count: 2
      expect(page).to have_content "Collection Information"
      expect(page).to have_content "Subjects, Formats, And Genres"
      expect(page).to have_content "Access And Usage Rights"
      expect(page).to have_content "Identifiers"
    end
  end

  # rubocop:disable Layout/LineLength
  context "Open with Permission objects not signed in" do
    it 'displays login message when accessing an OwP object and not logged in' do
      visit 'catalog/12345'
      expect(page).to have_content "The material in this folder is open for research use only with permission. Researchers who wish to gain access or who have received permission to view this item, please log in to your account to request permission or to view the materials in this folder."
    end
  end

  context "Open with Permission objects and signed in" do
    before do
      login_as user
    end
    it 'can access the object and view UV and metadata normally' do
      visit 'catalog/12345'
      expect(page).not_to have_content "The material in this folder is open for research use only with permission. Researchers who wish to gain access or who have received permission to view this item, please log in to your account to request permission or to view the materials in this folder."
      expect(page).not_to have_content "You are currently logged in to your account. However, you do not have permission to view this folder. If you would like to request permission, please fill out this form."
    end
    it 'displays login message when accessing an OwP object without access' do
      visit 'catalog/54321'
      expect(page).to have_content "You are currently logged in to your account. However, you do not have permission to view this folder. If you would like to request permission, please fill out this form."
    end
  end

  context "Open with Permission objects and signed in" do
    before do
      login_as request_user
    end
    it 'displays the terms and conditions if the user has not accepted them' do
      visit 'catalog/12345/request_form'
      expect(page).to have_content "You must accept the following terms and conditions in order to proceed."
      expect(page).to have_content "Permission Set Terms"
      expect(page).to have_content "These are some terms"
    end
  end

  context "Open with Permission objects and signed in" do
    before do
      login_as request_user
    end
    it 'displays the request form if the user has accepted the terms and conditions' do
      visit 'catalog/54321/request_form'
      expect(page).to have_content "Request Information"
      expect(page).to have_content "Full name:"
      expect(page).to have_content "Reason for request:"
    end
  end
  # rubocop:enable Layout/LineLength
end
