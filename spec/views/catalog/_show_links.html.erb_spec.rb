# frozen_string_literal: true

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'catalog/_show_tools.html.erb' do
  let(:document) { SolrDocument.new id: 'xyz', bib_id_ssm: ['123'] }

  before do
    assign :document, document
  end

  describe 'links' do
    it 'renders links' do
      render partial: 'catalog/show_links'
      expect(rendered).to have_selector '.show-links', text: 'Links'
    end

    it 'renders the iiif manifest link' do
      render partial: 'catalog/show_links'
      expect(rendered).to have_link 'Manifest Link', href: "http://localhost/manifests/xyz.json"
    end
  end
end
