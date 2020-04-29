# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'View a Work' do
  before do
    solr = Blacklight.default_index.connection
    solr.add(work_attributes)
    solr.commit
    allow(Rails.application.config).to receive(:iiif_url).and_return('https://example.com')
  end

  let(:id) { '123' }

  let(:work_attributes) do
    {
      id: id,
      has_model_ssim: ['Work'],
      title_tesim: ['The Title of my Work'],
      description_tesim: ['Description 1', 'Description 2']
    }
  end

  it 'has the uv html on the page' do
    visit solr_document_path(id)
    expect(page.html).to match(/universal-viewer-iframe/)
  end
end