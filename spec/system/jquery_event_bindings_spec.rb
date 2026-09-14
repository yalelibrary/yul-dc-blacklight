# frozen_string_literal: true

require 'rails_helper'

# Regression coverage for the handlers that were migrated off jQuery APIs which
# are deprecated in jQuery 3.x and scheduled for removal:
#
#   * `.click(fn)`            -> `.on('click', fn)`  -- app/assets/javascripts/application.js
#   * `$(document).ready(fn)` -> `$(fn)`             -- application.js, catalog/_uv.html.erb
#
# The markup for these behaviors is already covered elsewhere; what is covered
# here is the *binding*. Every example drives the handler through a real click
# or a real `message` event, so a handler that silently stops being registered
# fails here rather than in production.
RSpec.describe 'jQuery event bindings', type: :system, js: true, clean: true do
  let(:manifest_fixture) { File.open(File.join('spec', 'fixtures', '2041002.json')).read }

  # has_fulltext_ssi + Public visibility is what makes the "Show Full Text"
  # button render (see AccessHelper#display_fulltext_button?).
  let(:fulltext_parent) do
    {
      id: '111',
      title_tesim: ['Deprecation Llama'],
      format: 'text',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts',
      child_oids_ssim: [112, 113],
      oid_ssi: 111,
      has_fulltext_ssi: 'Yes'
    }
  end

  let(:fulltext_child) do
    {
      id: '112',
      title_tesim: ['Deprecation Llama Page One'],
      format: 'text',
      visibility_ssi: 'Public',
      parent_ssi: '111',
      child_fulltext_wstsim: ['Transcribed page one.'],
      has_fulltext_ssi: 'Yes'
    }
  end

  let(:plain_work) do
    {
      id: '222',
      title_tesim: ['Deprecation Bulldog'],
      format: 'text',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts',
      child_oids_ssim: [444, 555],
      oid_ssi: 222,
      has_fulltext_ssi: 'No'
    }
  end

  let(:caption_work) do
    {
      id: '999',
      title_tesim: ['Deprecation Captions'],
      format: 'text',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts',
      caption_tesim: ['112: Sketch of the Missouri River'],
      child_oids_ssim: [112],
      oid_ssi: 999,
      has_fulltext_ssi: 'No'
    }
  end

  let(:sensitive_work) do
    {
      id: '888',
      title_tesim: ['Deprecation Sensitive'],
      format: 'text',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts',
      sensitive_materials_ssi: 'Yes',
      child_oids_ssim: [555],
      oid_ssi: 888,
      has_fulltext_ssi: 'No'
    }
  end

  # Posts a `message` event at the window the same way the Universal Viewer
  # iframe does, so the listeners registered from the document-ready callbacks
  # are exercised for real.
  def post_uv_message(index)
    page.execute_script("window.postMessage(#{index}, window.location.origin)")
  end

  around do |example|
    original_sample_bucket = ENV['SAMPLE_BUCKET']
    ENV['SAMPLE_BUCKET'] = 'yul-dc-development-samples'
    example.run
    ENV['SAMPLE_BUCKET'] = original_sample_bucket
  end

  def stub_manifest(oid)
    pairtree = Partridge::Pairtree.oid_to_pairtree(oid)
    stub_request(:get, "https://#{ENV['SAMPLE_BUCKET']}.s3.amazonaws.com/manifests/#{pairtree}/#{oid}.json")
      .to_return(status: 200, body: manifest_fixture)
  end

  before do
    [111, 112, 113, 222, 888, 999].each { |oid| stub_manifest(oid) }

    solr = Blacklight.default_index.connection
    solr.add([fulltext_parent, fulltext_child, plain_work, caption_work, sensitive_work])
    solr.commit
  end

  describe 'href-button click handler' do
    before do
      visit '/catalog?search_field=all_fields&q='
      click_on 'Deprecation Llama', match: :first
    end

    it 'follows the href of the converted "Back to Search Results" button' do
      back_path = '/catalog?page=1&per_page=10&search_field=all_fields'
      expect(page).to have_content(/back to search results/i)

      find(:xpath, "//button[@href='#{back_path}']").click

      expect(page).to have_current_path(back_path)
    end

    it 'follows the href of the "New Search" button' do
      find('button.catalog_startOverLink').click

      expect(page).to have_current_path('/catalog')
    end
  end

  # The full text panel is hidden with the `.hidden` class, which only exists in
  # the compiled stylesheet, so this group needs styling loaded.
  describe 'full text toggle click handler', style: true do
    before { visit '/catalog/111' }

    it 'toggles the button label and aria-expanded on each click' do
      expect(page).to have_button('Show Full Text')

      click_on 'Show Full Text'

      expect(page).to have_button('Hide Full Text')
      expect(page.find('.fulltext-button')['aria-expanded']).to eq 'true'

      click_on 'Hide Full Text'

      expect(page).to have_button('Show Full Text')
      expect(page.find('.fulltext-button')['aria-expanded']).to eq 'false'
    end
  end

  describe 'caption toggle click handler' do
    before { visit '/catalog/999?show_captions=true&q=Missouri' }

    it 'hides the captions and relabels the button' do
      expect(page).to have_button('Hide Captions')
      expect(page).to have_css('.matching-captions-content', visible: :visible)

      click_on 'Hide Captions'

      expect(page).to have_button('Show Captions')
      expect(page.find('.caption-toggle-button')['aria-expanded']).to eq 'false'
      expect(page).to have_css('.matching-captions-content', visible: :hidden)
    end

    it 'shows the captions again on a second click' do
      click_on 'Hide Captions'
      click_on 'Show Captions'

      expect(page).to have_button('Hide Captions')
      expect(page.find('.caption-toggle-button')['aria-expanded']).to eq 'true'
      expect(page).to have_css('.matching-captions-content', visible: :visible)
    end
  end

  # `$(fn)` in app/views/catalog/_uv.html.erb.
  describe 'universal viewer document ready handler' do
    it 'records the child oid the viewer reports through postMessage' do
      visit '/catalog/222'
      expect(page).to have_css('#uv-pages')

      post_uv_message(1)

      expect(page).to have_css('#uv-pages', text: '555')
    end

    it 'toggles the sensitive materials overlay' do
      visit '/catalog/888'
      expect(page).to have_css('#sensitive-overlay', visible: :visible)

      click_on 'View Object'

      expect(page).to have_css('#sensitive-overlay', visible: :hidden)
      expect(page).to have_button('Hide Object')

      click_on 'Hide Object'

      expect(page).to have_css('#sensitive-overlay', visible: :visible)
    end
  end

  # `$(fn)` in app/assets/javascripts/application.js: the ready callback is what
  # registers the `message` listener that renders the transcription.
  describe 'full text render document ready handler' do
    it 'renders the transcription for the child oid the viewer reports' do
      visit '/catalog/111'
      expect(page).to have_button('Show Full Text')

      post_uv_message(0)

      expect(page).to have_css('#fulltext-transcription span',
                               text: 'Transcribed page one.',
                               visible: :all)
    end
  end
end
