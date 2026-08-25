# frozen_string_literal: true

RSpec.describe 'catalog/_fulltext_transcription.html.erb' do
  let(:document) { SolrDocument.new id: 'xyz', has_fulltext_ssi: fulltext_status }

  before do
    without_partial_double_verification do
      allow(view).to receive(:client_can_view_digital?).and_return can_view_digital
    end
    render partial: 'catalog/fulltext_transcription', locals: { document: document }
  end

  context 'when the object is fully transcribed' do
    let(:fulltext_status) { 'Yes' }

    context 'and the client can view the digital object' do
      let(:can_view_digital) { true }

      it 'renders the full text button' do
        expect(rendered).to have_selector 'section.item-page-fulltext-wrapper button.fulltext-button'
        expect(rendered).to have_text 'Show Full Text'
      end
    end

    context 'and the client cannot view the digital object' do
      let(:can_view_digital) { false }

      it 'does not render the full text button' do
        expect(rendered).not_to have_selector '.fulltext-button'
      end
    end
  end

  context 'when the object is partially transcribed' do
    let(:fulltext_status) { 'Partial' }

    context 'and the client can view the digital object' do
      let(:can_view_digital) { true }

      it 'renders the full text button' do
        expect(rendered).to have_selector '.fulltext-button'
      end
    end

    context 'and the client cannot view the digital object' do
      let(:can_view_digital) { false }

      it 'does not render the full text button' do
        expect(rendered).not_to have_selector '.fulltext-button'
      end
    end
  end

  context 'when the object has no full text' do
    let(:can_view_digital) { true }

    context 'with a status of No' do
      let(:fulltext_status) { 'No' }

      it 'does not render the full text button' do
        expect(rendered).not_to have_selector '.fulltext-button'
      end
    end

    context 'with no status at all' do
      let(:fulltext_status) { nil }

      it 'does not render the full text button' do
        expect(rendered).not_to have_selector '.fulltext-button'
      end
    end
  end
end
