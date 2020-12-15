# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "access restrictions", type: :system, clean: true do
  let(:user) { FactoryBot.create(:user) }
  # "A General dictionary of the English language"
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY }

  # "[Map of China]. [private copy]"
  let(:private_work) { WORK_WITH_PRIVATE_VISIBILITY }

  # "[Map of China]. [yale-only copy]"
  let(:yale_work) { WORK_WITH_YALE_ONLY_VISIBILITY }

  let(:cas) { WORK_WITH_YALE_ONLY_VISIBILITY }

  before do
    solr = Blacklight.default_index.connection
    solr.add(public_work)
    solr.add(private_work)
    solr.add(yale_work)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  context "an unauthenticated user" do
    it 'displays public and yale-only but NOT private works in search results' do
      visit '/catalog?search_field=all_fields&q='

      expect(page).to have_content('A General dictionary of the English language')
      expect(page).to have_content('[Map of China]. [yale-only copy]')
      expect(page).not_to have_content('[Map of China]. [private copy]')
    end

    it "displays universal viewer for public works" do
      visit solr_document_path(public_work[:id])
      expect(page.html).to match(/universal-viewer-iframe/)
    end

    it "does NOT display universal viewer for yale-only works" do
      visit solr_document_path(yale_work[:id])
      expect(page.html).not_to match(/universal-viewer-iframe/)
    end
  end

  context "an authenticated user" do
    before do
      login_as user
    end

    it 'displays public and yale-only but NOT private works in search results' do
      visit '/catalog?search_field=all_fields&q='

      expect(page).to have_content('A General dictionary of the English language')
      expect(page).to have_content('[Map of China]. [yale-only copy]')
      expect(page).not_to have_content('[Map of China]. [private copy]')
    end

    it "displays universal viewer for public works" do
      visit solr_document_path(public_work[:id])
      expect(page.html).to match(/universal-viewer-iframe/)
    end

    it "displays universal viewer for yale-only works" do
      visit solr_document_path(yale_work[:id])
      expect(page.html).to match(/universal-viewer-iframe/)
    end
  end

  context "an user on the network" do
    around do |example|
      original_yale_networks = ENV['YALE_NETWORK_IPS']
      ENV['YALE_NETWORK_IPS'] = "101.10.5.4,3.4.2.3"
      example.run
      ENV['YALE_NETWORK_IPS'] = original_yale_networks
    end

    before do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('101.10.5.4')
    end

    it 'displays public and yale-only but NOT private works in search results' do
      visit '/catalog?search_field=all_fields&q='
      expect(page).to have_content('A General dictionary of the English language')
      expect(page).to have_content('[Map of China]. [yale-only copy]')
      expect(page).not_to have_content('[Map of China]. [private copy]')
    end

    it "displays universal viewer for public works" do
      visit solr_document_path(public_work[:id])
      expect(page.html).to match(/universal-viewer-iframe/)
    end

    it "displays universal viewer for yale-only works" do
      visit solr_document_path(yale_work[:id])
      expect(page.html).to match(/universal-viewer-iframe/)
    end
  end
end
