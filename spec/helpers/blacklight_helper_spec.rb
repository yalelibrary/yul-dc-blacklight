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

  describe '#render_thumbnail' do
    context 'with public record and oid with images' do
      let(:valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssim: ['2055095']) }
      let(:non_valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssim: ['2055095']) }

      it 'returns an image_tag for oids that have images' do
        expect(helper.render_thumbnail(valid_document, { alt: "" })).to eq "<img src=\"https://collections-test.curationexperts.com/iiif/2/1234822/full/,200/0/default.jpg\" />"
      end
      xit 'returns an image_tag pointing to image_not_found.png for oids without images' do
        expect(helper.render_thumbnail(non_valid_document, {})).to eq 'image tag pointing to image_not_found.png'
      end
    end
  end
end
