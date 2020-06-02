# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Only show public works", type: :system, clean: true do
  let(:user) { FactoryBot.create(:user) }
  # "A General dictionary of the English language"
  let(:public_work) { WORK_WITH_PUBLIC_VISIBILITY }

  # "[Map of China]. [private copy]"
  let(:private_work) { WORK_WITH_PRIVATE_VISIBILITY }

  # "[Map of China]. [yale-only copy]"
  let(:yale_work) { WORK_WITH_YALE_ONLY_VISIBILITY }

  before do
    solr = Blacklight.default_index.connection
    solr.add(public_work)
    solr.add(private_work)
    solr.add(yale_work)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  context "an unauthenticated user" do
    it 'displays only public works' do
      visit '/?search_field=all_fields&q='

      expect(page).to have_content('A General dictionary of the English language')
      expect(page).not_to have_content('[Map of China]. [yale-only copy]')
      expect(page).not_to have_content('[Map of China]. [private copy]')
    end
  end

  context "an authenticated user" do
    xit 'displays public and yale-only works' do
      login_as user
      visit '/?search_field=all_fields&q='

      expect(page).to have_content('A General dictionary of the English language')
      expect(page).to have_content('[Map of China]. [yale-only copy]')
      expect(page).not_to have_content('[Map of China]. [private copy]')
    end
  end
end
