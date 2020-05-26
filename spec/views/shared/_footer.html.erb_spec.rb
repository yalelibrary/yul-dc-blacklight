# frozen_string_literal: true

RSpec::Mocks.configuration.allow_message_expectations_on_nil = true

RSpec.describe 'shared/_footer.html.erb' do
  let(:document) { SolrDocument.new id: 'xyz', bib_id_ssm: ['123'] }

  before do
    assign :document, document
  end

  describe 'footer' do
    it 'renders the branch information in the footer' do
      render partial: 'shared/footer.html.erb'
      expect(rendered).to have_content('Branch:')
    end
    it 'renders the deployment information in the footer' do
      render partial: 'shared/footer.html.erb'
      expect(rendered).to have_content('Deployed:')
    end
  end
end
