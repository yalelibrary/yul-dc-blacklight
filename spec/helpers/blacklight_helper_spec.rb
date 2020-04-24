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
end
