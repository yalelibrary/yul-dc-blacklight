# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fulltext display', type: :system, clean: true, js: true, style: true do
  let(:user) { FactoryBot.create(:user, netid: "netid") }
  let(:public_work) do
    {
      "id": "2041003",
      "title_tesim": ["English Dictionary. [public copy]"],
      "fulltext_tesim": ["This is the full text public", "This some additional full text that is public", "This is even more full text that is public"],
      "child_oids_ssim": ["1014979", "1014980", "1014981"],
      "visibility_ssi": "Public",
      "has_fulltext_ssi": "Yes"
    }
  end
  let(:child_work_one) do
    {
      "id": "1014979",
      "parent_ssi": "2041003",
      "child_fulltext_wstsim": ["This is the full text public"]
    }
  end
  let(:child_work_two) do
    {
      "id": "1014980",
      "parent_ssi": "2041003",
      "child_fulltext_wstsim": ["This some additional full text that is public"]
    }
  end
  let(:child_work_three) do
    {
      "id": "1014981",
      "parent_ssi": "2041003",
      "child_fulltext_wstsim": ["This even more full text that is public"]
    }
  end

  around do |example|
    original_sample_bucket = ENV['SAMPLE_BUCKET']
    original_blacklight_host = ENV['BLACKLIGHT_HOST']
    ENV['SAMPLE_BUCKET'] = 'example'
    ENV['BLACKLIGHT_HOST'] = 'blacklight'
    example.run
    ENV['SAMPLE_BUCKET'] = original_sample_bucket
    ENV['BLACKLIGHT_HOST'] = original_blacklight_host
  end

  before do
    manifest = JSON.parse(File.read(Rails.root.join('spec', 'fixtures', '2041003.json')))
    manifest['sequences'][0]['canvases'].each do |canvas|
      canvas['images'][0]['resource']['@id'] = "#{Capybara.app_host}/images/access-image-v2.png"
    end
    stub_request(:get, "https://example.s3.amazonaws.com/manifests/03/20/41/00/2041003.json")
      .to_return(status: 200, body: manifest.to_json, headers: {})
    solr = Blacklight.default_index.connection
    solr.add([public_work, child_work_one, child_work_two, child_work_three])
    solr.commit
  end

  context 'Regular user' do
    before do
      login_as user
    end

    # manifest must have 'paged' ViewingHint for 2 up view option in UV
    it 'can view full text content in 2 up view' do
      visit "/catalog/#{public_work[:id]}"
      page.driver.browser.manage.window.resize_to(1400, 2600)

      expect(page).to have_content 'Show Full Text'
      expect(page).not_to have_content 'full text public'
      click_on 'Show Full Text'
      within('#fulltext-transcription') do
        expect(page).to have_content 'full text public'
      end
      visit "/catalog/#{public_work[:id]}?child_oid=1014980"
      expect(page).to have_content 'Show Full Text'
      click_on 'Show Full Text'
      within('#fulltext-transcription') do
        expect(page).not_to have_content 'full text public'
        expect(page).to have_content 'some additional'
        expect(page).to have_content 'even more'
      end
    end
  end
end
