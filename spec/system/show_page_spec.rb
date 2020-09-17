# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Show Page', type: :system, js: :true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([llama,
              dog,
              eagle,
              puppy])
    solr.commit
    visit '?search_field=all_fields&q='
    click_on 'Amor Llama'
  end

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      author_ssim: ['Anna Elizabeth Dewdney']
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
      author_ssim: ['Andy Graves']
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
      author_ssim: ['Andrew Norriss']
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
      author_ssim: ['Paulo Coelho']
    }
  end

  it 'has expected css' do
    expect(page).to have_css '.btn-show'
    expect(page).to have_css '.constraints-container'
    expect(page).to have_css '.show-buttons'
    expect(page).to have_css '.link-card-header'
    expect(page).to have_css '.manifest'
  end
  context '"Back to Search" button' do
    it 'returns user to search results' do
      expect(page).to have_link("Back to Search", href: "/?page=1&per_page=10&search_field=all_fields")
    end
  end
  context '"Start Over" button' do
    it 'returns user to homepage' do
      expect(page).to have_link("Start Over", href: "/")
    end
  end
end
