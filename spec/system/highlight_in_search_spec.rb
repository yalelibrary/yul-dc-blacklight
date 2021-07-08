# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays field', type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([dog])
    solr.commit
  end

  let(:dog) do
    {
      id: '111',
      title_tesim: 'Jack or Dan the Bulldog',
      creator_tesim: 'Me and You',
      abstract_tesim: 'Binding: white with gold embossing.',
      alternativeTitle_tesim: 'The Yale Bulldogs',
      description_tesim: 'in black ink on thin white paper',
      format: 'three dimensional object',
      callNumber_tesim: 'Osborn Music MS 4',
      published_ssim: "1997",
      language_ssim: ['en', 'eng', 'zz'],
      publisher_tesim: 'Printed for Eric',
      resourceType_tesim: "Music (Printed & Manuscript)",
      sourceCreated_tesim: 'The Whale',
      subjectGeographic_tesim: 'United States--Maps, Manuscript',
      subjectTopic_tesim: 'Phrenology--United States',
      subjectName_tesim: 'Price, Leo',
      visibility_ssi: 'Public'
    }
  end

  context 'Within search results' do
    subject(:content) { find(:css, '#content') }

    it 'highlights title when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Dan'
      expect(page.html).to include "Jack or <span class='search-highlight'>Dan</span> the Bulldog"
    end

    it 'highlights abstract when a term is queried' do
      visit '/catalog?search_field=all_fields&q=white'
      expect(page.html).to include "Binding: <span class='search-highlight'>white</span> with gold embossing."
    end

    it 'highlights publisher when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Eric'
      expect(page.html).to include "Printed for <span class='search-highlight'>Eric</span>"
    end

    it 'highlights description when a term is queried' do
      visit '/catalog?search_field=all_fields&q=white'
      expect(page.html).to include "in black ink on thin <span class='search-highlight'>white</span> paper"
    end

    it 'highlights created source when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Whale'
      expect(page.html).to include "The <span class='search-highlight'>Whale</span>"
    end

    it 'highlights geographic subject when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Maps'
      expect(page.html).to include "United States--<span class='search-highlight'>Maps</span>, Manuscript"
    end

    it 'highlights topic subject when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Phrenology'
      expect(page.html).to include "<span class='search-highlight'>Phrenology</span>--United States"
    end

    it 'highlights author when a term is queried' do
      visit '/catalog?search_field=all_fields&q=You'
      expect(page.html).to include "Me and <span class='search-highlight'>You</span>"
    end

    it 'highlights name subject when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Leo'
      expect(page.html).to include "Price, <span class='search-highlight'>Leo</span>"
    end

    it 'highlights the resource type when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Music'
      expect(page.html).to include "<span class='search-highlight'>Music</span> (Printed & Manuscript)"
    end

    it 'highlights the call number when a term is queried' do
      visit '/catalog?search_field=all_fields&q=Music'
      expect(page.html).to include "Osborn <span class='search-highlight'>Music</span> MS 4"
    end
  end
end
