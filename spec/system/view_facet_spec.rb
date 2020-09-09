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

  it 'can filter results with format facets' do
    click_on 'FORMAT'
    click_on 'text'
    expect(page).to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with language facets' do
    click_on 'LANGUAGE'
    click_on 'Latin (la)'
    expect(page).to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with genre facets' do
    click_on 'GENRE'
    click_on 'Animation'
    expect(page).to have_content('Rhett Lecheire')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
  end

  it 'can filter results with resource type facets' do
    click_on 'RESOURCE TYPE'
    click_on 'Archives or Manuscripts'
    expect(page).to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with author facets' do
    click_on 'AUTHOR'
    click_on 'Andy Graves'
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
  end

  it 'does not show the Identifier Shelf Mark facet' do
    expect(page).not_to have_content('Identifier Shelf Mark')
  end

  it 'renders the facet header' do
    expect(page).to have_css('.facet-field-heading')
  end

  it 'renders the facet label' do
    click_on 'RESOURCE TYPE'
    expect(page).to have_css('.facet-label')
  end

  it 'renders the facet count' do
    click_on 'RESOURCE TYPE'
    expect(page).to have_css('.facet-count')
  end

  it 'does not render the x as text' do
    click_on 'RESOURCE TYPE'
    click_on 'Archives or Manuscripts'
    expect(page).to have_no_css('.remove-icon')
  end

  it 'renders the x png' do
    click_on 'GENRE'
    click_on 'Animation'
    expect(page).to have_css('.remove')
  end
end
