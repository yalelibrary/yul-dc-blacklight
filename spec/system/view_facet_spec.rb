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
      title_tsim: ['Amor Llama'],
      format: 'text',
      language_ssim: 'la',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Maps, Atlases & Globes'
    }
  end

  let(:dog) do
    {
      id: '222',
      title_tsim: ['HandsomeDan Bulldog'],
      format: 'three dimensional object',
      language_ssim: 'en',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Books, Journals & Pamphlets'
    }
  end

  let(:eagle) do
    {
      id: '333',
      title_tsim: ['Aquila Eccellenza'],
      format: 'still image',
      language_ssim: 'it',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts'
    }
  end

  let(:puppy) do
    {
      id: '444',
      title_tsim: ['Rhett Lecheire'],
      format: 'text',
      language_ssim: 'fr',
      visibility_ssi: 'Public',
      resourceType_ssim: 'Archives or Manuscripts'
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

  it 'can filter results with resource type facets' do
    click_on 'Resource Type'
    click_on 'Archives or Manuscripts'
    expect(page).to have_content('Aquila Eccellenza')
    expect(page).not_to have_content('Amor Llama')
    expect(page).not_to have_content('HandsomeDan Bulldog')
  end
end
