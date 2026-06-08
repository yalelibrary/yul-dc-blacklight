# frozen_string_literal: true

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'catalog/_uv.html.erb' do
  let(:document) { SolrDocument.new id: 'xyz', bib_id_ssm: ['123'], visibility_ssi: "Public" }
  let(:document2) { SolrDocument.new id: 'xyz', bib_id_ssm: ['123'], visibility_ssi: "Yale-Community Only" }
  let(:blacklight_config) { Blacklight::Configuration.new }
  let(:current_search_session) { double('SearchSession', id: 'abc') }

  before do
    assign :document, document
    without_partial_double_verification do
      allow(view).to receive(:blacklight_config).and_return blacklight_config
      allow(view).to receive(:current_search_session).and_return current_search_session
      allow(view).to receive(:show_doc_actions?).and_return true
    end
  end

  it 'renders the iiif manifest image with proper zoom level' do
    render partial: 'catalog/uv', locals: { document: document }
    within '#uv' do
      expect(rendered).to have_selector "iframe[src='http://test.host/uv/123/manifest.json?canvas=0&cv=0']"
      # get viewport size
      expect(rendered).to have_selector "iframe[width='400']"
      expect(rendered).to have_selector "iframe[height='400']"
      # get zoom level
      viewport_height = page.evaluate_script("document.querySelector('#uv iframe').contentWindow.document.querySelector('.uv-viewport').clientHeight")
      viewport_width = page.evaluate_script("document.querySelector('#uv iframe').contentWindow.document.querySelector('.uv-viewport').clientWidth")
      image_height = page.evaluate_script("document.querySelector('#uv iframe').contentWindow.document.querySelector('.uv-canvas').clientHeight")
      image_width = page.evaluate_script("document.querySelector('#uv iframe').contentWindow.document.querySelector('.uv-canvas').clientWidth")
      # calculate the filled ratio
      filled_ratio = [image_width.to_f / viewport_width, image_height.to_f / viewport_height].max
      # expect the ratio to be what zoom level is set to in the UV config
      expect(filled_ratio).to eq(UV.modules.openSeadragonCenterPanel.options.defaultZoomLevel)
    end
  end
end
