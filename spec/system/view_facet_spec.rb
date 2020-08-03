# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Facets should display', type: :system, js: :true, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([llama,
              dog,
              eagle,
              puppy])
    solr.commit
    visit root_path
  end

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      publicationPlace_ssim: 'Spain',
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
      publicationPlace_ssim: 'New Haven',
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
      publicationPlace_ssim: 'White-Hall, printed upon the ice, on the River Thames',
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
      publicationPlace_ssim: 'Constantinople or southern Italy',
      resourceType_ssim: 'Archives or Manuscripts',
      author_ssim: ['Paulo Coelho']
    }
  end

  it 'can filter results with format facets' do
    click_on 'Format'
    click_on 'text'
    expect(page).to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with language facets' do
    click_on 'Language'
    click_on 'Latin (la)'
    expect(page).to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with publication place facets' do
    click_on 'Publication Place'
    click_on 'New Haven'
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
  end

  it 'can filter results with resource type facets' do
    click_on 'Resource Type'
    click_on 'Archives or Manuscripts'
    expect(page).to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with author facets' do
    click_on 'Author'
    click_on 'Andy Graves'
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
  end

  it 'does not show the Identifier Shelf Mark facet' do
    expect(page).not_to have_content('Identifier Shelf Mark')
  end
end
