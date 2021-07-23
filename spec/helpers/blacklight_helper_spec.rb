# frozen_string_literal: true

RSpec.describe BlacklightHelper, helper: true, style: true do
  include Devise::Test::ControllerHelpers

  # used so render_thumbnail can get user info from rspec
  def user_signed_in?
    user.present?
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

  describe 'link to url with label' do
    context 'with a list of links with labels' do
      let(:document) { SolrDocument.new(id: 'xyz') }
      let(:args) do
        {
          document: document,
          field: 'relatedResourceOnline_ssim',
          value: ['View Related Resource|http://library.somewhere.com/special_page', 'http://library.somewhereelse.com/special_page', 'View Related Resource| not']
        }
      end

      it 'returns a list of links with labels' do
        # rubocop:disable Layout/LineLength
        expect(helper.link_to_url_with_label(args)).to eq "<a href=\"http://library.somewhere.com/special_page\">View Related Resource</a><br/><a href=\"http://library.somewhereelse.com/special_page\">http://library.somewhereelse.com/special_page</a>"
        # rubocop:enable Layout/LineLength
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

      describe '#range_unknown_remove_url' do
        let(:missing_url) { "/catalog?range%5Byear_isim%5D%5Bmissing%5D=true&search_field=all_fields" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        it 'filters out missing when x is clicked' do
          expect(helper.range_unknown_remove_url(missing_url)).to match clean_url
        end
      end

      describe '#range_remove_url' do
        let(:date_facet_url) { "/catalog?search_field=all_fields&range%5Byear_isim%5D%5Bbegin%5D=1116&range%5Byear_isim%5D%5Bend%5D=2002&commit=Apply" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        it 'filters out date range when x is clicked' do
          expect(helper.range_remove_url(date_facet_url)).to match clean_url
        end
      end

      describe '#get_date_constraint_params' do
        let(:missing_url) { "/catalog?range%5Byear_isim%5D%5Bmissing%5D=true&search_field=all_fields" }
        let(:date_facet_url) { "/catalog?search_field=all_fields&range%5Byear_isim%5D%5Bbegin%5D=1116&range%5Byear_isim%5D%5Bend%5D=2002&commit=Apply" }
        let(:clean_url) { %r{catalog[?&]search_field=all_fields} }

        context 'with missing date facet applied' do
          let(:params) do
            params = Hash.new { |h, k| h[k] = h.dup.clear }
            params["range"]["year_isim"]["missing"] = true
            params
          end
          it 'assigns the correct values to options' do
            value, label, options = helper.get_date_constraint_params(params, missing_url)
            expect(value).to eq "Unknown"
            expect(label).to eq "Date"
            expect(options[:classes]).to match ["year_isim"]
            expect(options[:remove]).to match clean_url
          end
        end
        context 'with a date range face applied' do
          let(:params) do
            params = Hash.new { |h, k| h[k] = h.dup.clear }
            params["range"]["year_isim"]["missing"] = false
            params["range"] = Object.new
            params["range"].define_singleton_method(:values) do
              @values ||= [Hash.new { |h, k| h[k] = h.dup.clear }]
              @values
            end
            params["range"].values[0]["begin"] = 1500
            params["range"].values[0]["end"] = 2000

            params
          end
          it 'assigns the correct values to options' do
            value, label, options = helper.get_date_constraint_params(params, date_facet_url)
            expect(value).to eq "1500 - 2000"
            expect(label).to eq "Date"
            expect(options[:classes]).to match ["year_isim"]
            expect(options[:remove]).to match clean_url
          end
        end
      end
    end
  end
end
