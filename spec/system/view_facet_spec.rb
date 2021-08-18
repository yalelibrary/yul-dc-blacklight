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
    visit search_catalog_path
  end

  let(:llama) do
    {
      id: '111',
      title_tesim: ['Amor Llama'],
      repository_ssi: 'Yale University Arts Library',
      collection_title_ssi: ['AAA'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Yale Community Only',
      genre_ssim: 'Maps',
      resourceType_ssim: 'Maps, Atlases & Globes',
      creator_ssim: ['Anna Elizabeth Dewdney']
    }
  end

  let(:dog) do
    {
      id: '222',
      title_tesim: ['HandsomeDan Bulldog'],
      repository_ssi: 'Yale University Arts Library',
      collection_title_ssi: ['AAA'],
      format: 'three dimensional object',
      language_ssim: 'en',
      visibility_ssi: 'Public',
      genre_ssim: 'Artifacts',
      resourceType_ssim: 'Books, Journals & Pamphlets',
      creator_ssim: ['Andy Graves']
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
      creator_ssim: ['Andrew Norriss']
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
      creator_ssim: ['Paulo Coelho']
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

  it 'can filter results with repository facets' do
    click_on 'Repository'
    click_on 'Yale University Arts Library'
    expect(page).to have_content('Amor Llama')
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Aquila Eccellenza')
  end

  it 'does not display the collection title facet by default' do
    expect(page).not_to have_css('.blacklight-collection_title_ssi')
  end

  it 'can filter results with collection title facets when a repository is selected' do
    click_on 'Repository'
    click_on 'Yale University Arts Library'
    click_on 'Collection Title'
    click_on 'AAA'
    expect(page).to have_content('Amor Llama')
    expect(page).not_to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Aquila Eccellenza')
  end

  it 'can filter results with genre facets' do
    click_on 'Genre'
    click_on 'Animation'
    expect(page).to have_content('Rhett Lecheire')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('Aquila Eccellenza')
  end

  it 'can filter results with visibility facets' do
    click_on 'Access'
    click_on 'Public'
    expect(page).to have_content('Rhett Lecheire')
    expect(page).to have_content('Aquila Eccellenza')
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Amor Llama')
  end

  it 'can filter results with resource type facets' do
    click_on 'Resource Type'
    click_on 'Archives or Manuscripts'
    expect(page).to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end

  it 'can filter results with creator facets' do
    click_on 'Creator'
    click_on 'Andy Graves'
    expect(page).to have_content('HandsomeDan Bulldog')
    expect(page).not_to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
  end

  it 'renders the facet header' do
    expect(page).to have_css('.facet-field-heading')
  end

  it 'renders the facet label' do
    click_on 'Resource Type'
    expect(page).to have_css('.facet-label')
  end

  it 'renders the facet count' do
    click_on 'Resource Type'
    expect(page).to have_css('.facet-count')
  end

  it 'does not render the x as text' do
    click_on 'Resource Type'
    click_on 'Archives or Manuscripts'
    expect(page).to have_no_css('.remove-icon')
  end

  it 'renders the x png' do
    click_on 'Genre'
    click_on 'Animation'
    expect(page).to have_css('.remove')
  end

  it 'removes the facet constraint when the x png is clicked' do
    click_on 'Genre'
    click_on 'Animation'
    click_on 'remove'
    expect(page).to have_no_css('.selected')
  end

  it 'removes the collection facet when the repository facet is removed' do
    click_on 'Repository'
    click_on 'Yale University Arts Library'
    click_on 'Collection Title'
    click_on 'AAA'
    within '#facet-repository_ssi' do
      click_on 'remove'
    end
    expect(page).not_to have_content('AAA')
  end
end
