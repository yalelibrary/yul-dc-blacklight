# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Fulltext search', type: :system, clean: true, js: true do
  let(:user) { FactoryBot.create(:user) }
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

  before do
    solr = Blacklight.default_index.connection
    solr.add([public_work, yale_work, child_work, child_work_yale_only])
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
  end

  context 'User with no permissions' do
    before do
      allow(User).to receive(:on_campus?).and_return(false)
    end

    it 'cannot view YCO full text search results' do
      visit '/catalog?search_field=fulltext_tesim&fulltext_search=2&q=full'
      expect(page).not_to have_content 'full text Yale only'
      expect(page).to have_content 'full text public'
    end
  end
end
