# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Only show public works", type: :system, clean: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add(public_work)
    solr.add(private_work)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  let(:public_work) do
    {
      id: '123',
      has_model_ssim: ['Work'],
      title_tsim: ['The Title of my Public Work'],
      description_tesim: ['Description 1', 'Description 2'],
      oid_ssm: ['abc123'],
      public_bsi: 1
    }
  end

  let(:private_work) do
    {
      id: '124',
      has_model_ssim: ['Work'],
      title_tsim: ['The Title of my Private Work'],
      description_tesim: ['Description 1', 'Description 2'],
      oid_ssm: ['abc123'],
      public_bsi: 0
    }
  end

  it 'displays public works' do
    visit '/?search_field=all_fields&q='

    expect(page).to have_content('The Title of my Public Work')
    expect(page).not_to have_content('The Title of my Private Work')
  end
end
