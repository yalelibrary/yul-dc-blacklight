# frozen_string_literal: true

RSpec.describe BlacklightHelper, helper: true, style: true do
  include Devise::Test::ControllerHelpers

  # used so render_thumbnail can get user info from rspec
  def user_signed_in?
    user.present?
  end

  describe '#manifest_url' do
    context 'when IIIF_MANIFESTS_BASE_URL is set' do
      around do |example|
        original_iiif_manifests_url = ENV['IIIF_MANIFESTS_BASE_URL']
        original_pdf_url = ENV['PDF_BASE_URL']
        ENV['IIIF_MANIFESTS_BASE_URL'] = 'http://example.com'
        ENV['PDF_BASE_URL'] = 'http://example.com'
        example.run
        ENV['IIIF_MANIFESTS_BASE_URL'] = original_iiif_manifests_url
        ENV['PDF_BASE_URL'] = original_pdf_url
      end

      it "defaults to 'Blacklight'" do
        expect(helper.manifest_url('foo')).to eq 'http://example.com/foo.json'
      end

      it "can find the pdf with defaults" do
        expect(helper.pdf_url('foo')).to eq 'http://example.com/foo.pdf'
      end
    end

    context 'when IIIF_MANIFESTS_BASE_URL is not set' do
      around do |example|
        original_iiif_manifests_url = ENV['IIIF_MANIFESTS_BASE_URL']
        ENV['IIIF_MANIFESTS_BASE_URL'] = nil
        example.run
        ENV['IIIF_MANIFESTS_BASE_URL'] = original_iiif_manifests_url
      end

      it "can find the pdf" do
        expect(helper.pdf_url('foo')).to eq 'http://localhost/pdfs/foo.pdf'
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
      let(:valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssi: ['2055095'], thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/!200,200/0/default.jpg") }
      let(:non_valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssi: ['9999999999999999']) }
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end
      it 'returns an image_tag for oids that have images' do
        expect(helper.render_thumbnail(valid_document, { alt: "" })).to match "<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/!200,200/0/default.jpg\" />"
      end
      it 'returns an image_tag pointing to image_not_found.png for oids without images' do
        expect(helper.render_thumbnail(non_valid_document, {})).to include("<img src=\"/assets/image_not_found-")
      end
    end

    context 'with Yale only records' do
      let(:yale_only_document) do
        SolrDocument.new(
          id: 'test',
          visibility_ssi: 'Yale Community Only',
          oid_ssi: ['2055095'],
          thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/!200,200/0/default.jpg"
        )
      end
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end

      it 'returns placeholder when logged out' do
        expect(helper.render_thumbnail(yale_only_document, {})).to include("<img src=\"/assets/placeholder_restricted-")
      end

      it 'returns image when logged in' do
        user = FactoryBot.create(:user)
        sign_in(user) # sign_in so user_signed_in? works in method

        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/!200,200/0/default.jpg\" />")
      end
    end
  end
end
