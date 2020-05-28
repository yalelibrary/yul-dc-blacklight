# frozen_string_literal: true

RSpec.describe BlacklightHelper do
  describe '#manifest_url' do
    context 'when IIIF_MANIFESTS_BASE_URL is set' do
      before do
        ENV['IIIF_MANIFESTS_BASE_URL'] = 'http://example.com'
      end

      it "defaults to 'Blacklight'" do
        expect(helper.manifest_url('foo')).to eq 'http://example.com/foo.json'
      end
    end

    context 'when IIIF_MANIFESTS_BASE_URL is not set' do
      before do
        ENV['IIIF_MANIFESTS_BASE_URL'] = nil
      end

      it "defaults to 'Blacklight'" do
        expect(helper.manifest_url('foo')).to eq 'http://localhost/manifests/foo.json'
      end
    end
  end

  describe '#language_code' do
    context 'with a valid language code' do
      it 'returns the English name of the language' do
        expect(helper.language_code('en')).to eq 'English (en)'
      end
    end

    context 'with an invalid language code' do
      it 'returns the the invalid language code' do
        expect(helper.language_code('zz')).to eq 'zz'
      end
    end
  end

  describe '#language_codes' do
    context 'with a list of language code values' do
      let(:document) { SolrDocument.new(id: 'xyz', language_ssim: ['en', 'eng', 'zz']) }
      let(:args) do
        {
          document: document,
          field: 'language_ssim',
          value: ['en', 'eng', 'zz']
        }
      end

      it 'returns a list of English names of the languages, if available' do
        expect(helper.language_codes(args)).to eq 'English (en), English (eng), zz'
      end
    end
  end
end
