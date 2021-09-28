# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Ancestor Title Hierarchy Search', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([anc1, anc2])
    solr.commit
    visit '/catalog?search_field=all_fields&q='
  end

  let(:anc1) do
    {
      id: '222221',
      title_tesim: 'Betty Sapir. New Hampshire (697-567)',
      creator_tesim: 'Lakeisha',
      ancestor_titles_hierarchy_ssim: [
        "Beinecke > ",
        "Beinecke > David > ",
        "Beinecke > David > Photo > ",
        "Beinecke > David > Photo > June > "
      ],
      subjectName_tesim: "this is the subject name",
      sourceTitle_tesim: "this is the source title",
      callNumber_tesim: 'WAMSS987',
      orbisBibId_ssi: '1238901',
      visibility_ssi: 'Public'
    }
  end

  let(:anc2) do
    {
      id: '222222',
      title_tesim: 'Second Ancestor Test',
      ancestor_titles_hierarchy_ssim: [
        "Beinecke > ",
        "Beinecke > David > ",
        "Beinecke > David > Drawing > ",
        "Beinecke > David > Drawing > June > "
      ],
      subjectName_tesim: "this is the subject name",
      sourceTitle_tesim: "this is the source title",
      callNumber_tesim: 'CALLNUM2',
      orbisBibId_ssi: '1238902',
      visibility_ssi: 'Public'
    }
  end

  context 'result' do
    subject(:content) { find(:css, '#content') }

    it 'search the first level' do
      visit '/catalog?f[ancestor_titles_hierarchy_ssim][]=Beinecke > '
      expect(page).to have_content("Betty Sapir. New Hampshire (697-567)")
      expect(page).to have_content "Arts Library Bass Library"
    end

    it 'search the second level' do
      visit '/catalog?f[ancestor_titles_hierarchy_ssim][]=Beinecke > David > '
      expect(page).to have_content "Betty Sapir. New Hampshire (697-567)"
      expect(page).to have_content "Second Ancestor Test"
    end

    it 'search the third level' do
      visit '/catalog?f[ancestor_titles_hierarchy_ssim][]=Beinecke > David > Drawing > '
      expect(page).to have_content "Second Ancestor Test"
    end

    it 'search the fourth level' do
      visit '/catalog?f[ancestor_titles_hierarchy_ssim][]=Beinecke > David > Photo > June > '
      expect(page).to have_content "Betty Sapir. New Hampshire (697-567)"
    end
  end
end
