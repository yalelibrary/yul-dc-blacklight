# frozen_string_literal: true
require 'rails_helper'

RSpec.feature "View Search Results", type: :system, clean: true, js: false do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record_0, test_record_1, test_record_2])
    solr.commit
    # visit '/catalog/211'
  end

  let(:test_record_0) do
    {
      id: '211',
      subtitle_tesim: "He's Handsome",
      author_tesim: 'Eric & Frederick',
      author_vern_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/211',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/211',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      dateStructured_ssim: "1920"
    }
  end

  let(:test_record_1) do
    {
      id: '311',
      subtitle_tesim: "He's Dan",
      author_tesim: 'Eric & Frederick',
      author_vern_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/311',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/311',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      dateStructured_ssim: "1900"
    }
  end

  let(:test_record_2) do
    {
      id: '411',
      subtitle_tesim: "He's Handsome Dan",
      author_tesim: 'Eric & Frederick',
      author_vern_ssim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/411',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/411',
      published_ssim: "1997",
      published_vern_ssim: "1997",
      lc_callnum_ssim: "123213213",
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      dateStructured_ssim: "2020"
    }
  end

  it 'gets correct search results using year ranges' do
    visit root_path
    click_on 'search'

    within '#documents' do
      expect(page).to have_content("211")
      expect(page).to have_content("311")
      expect(page).to have_content("411")
    end

    fill_in 'range_dateStructured_ssim_begin', with: '1910'
    fill_in 'range_dateStructured_ssim_end', with: '1950'
    click_on 'Apply'

    within '#documents' do
      expect(page).to     have_content("211")
      expect(page).not_to have_content("311")
      expect(page).not_to have_content('411')
    end
  end
end
