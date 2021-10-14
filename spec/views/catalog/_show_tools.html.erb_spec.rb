# frozen_string_literal: true

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'catalog/_show_tools.html.erb' do
  let(:document) { SolrDocument.new id: 'xyz', bib_id_ssm: ['123'] }
  let(:blacklight_config) { Blacklight::Configuration.new }

  before do
    assign :document, document
    without_partial_double_verification do
      allow(view).to receive(:blacklight_config).and_return blacklight_config
      allow(view).to receive(:show_doc_actions?).and_return true
    end
  end

  context 'with documents and user access' do
    before do
      stub_request(:head, "http://test.host/manifests/xyz")
        .with(
            headers: {
              'Accept' => '*/*',
              'User-Agent' => 'Ruby'
            }
          )
        .to_return(status: 200, body: "", headers: {})
      stub_request(:head, "http://test.host/mirador/xyz")
        .with(
            headers: {
              'Accept' => '*/*',
              'User-Agent' => 'Ruby'
            }
          )
        .to_return(status: 200, body: "", headers: {})
      stub_request(:head, "http://test.host/pdfs/xyz")
        .with(
            headers: {
              'Accept' => '*/*',
              'User-Agent' => 'Ruby'
            }
          )
        .to_return(status: 200, body: "", headers: {})
    end

    describe 'links' do
      it 'renders the iiif manifest link' do
        render partial: 'catalog/show_tools'
        expect(rendered).to have_link 'Manifest Link', href: "http://test.host/manifests/xyz"
      end

      it 'renders the mirador link' do
        render partial: 'catalog/show_tools'
        expect(rendered).to have_link 'View in Mirador', href: "/mirador/xyz"
      end

      it 'renders the pdf link' do
        render partial: 'catalog/show_tools'
        expect(rendered).to have_link 'Download as PDF', href: "http://test.host/pdfs/xyz.pdf"
      end
    end
  end
end
