# frozen_string_literal: true

RSpec.describe BlacklightHelper, helper: true, style: true do
  include Devise::Test::ControllerHelpers
  let(:thumbnail_size) { "!200,200" }

  # used so render_thumbnail can get user info from rspec
  def user_signed_in?
    user.present?
  end

  describe '#fulltext_snippet_separation' do
    let(:document) do
      SolrDocument.new(
      id: 'fulltext',
      visibility_ssi: 'Public',
      fulltext_tesim: ["This is a test.\n\nThis is the OCR <span class='search-highlight'>text</span>", " for 1030368.\n\nSearch for some <span class='search-highlight'>text</span> to see"]
    )
    end

    it 'separates the snippets by line breaks' do
      options = {
        value: ["This is a test.\n\nThis is the OCR <span class='search-highlight'>text</span>", " for 1030368.\n\nSearch for some <span class='search-highlight'>text</span> to see"],
        document: document
      }

      expect(helper.fulltext_snippet_separation(options)).to eq(
        "<p>This is a test.  This is the OCR <span class=\"search-highlight\">text</span><br> for 1030368.  Search for some <span class=\"search-highlight\">text</span> to see</p>"
      )
    end
  end

  describe '#aspace_link' do
    let(:document) { SolrDocument.new(id: 'aspace_link', archiveSpaceUri_ssi: '/repositories/11/archival_objects/21463') }
    let(:args) do
      {
        document: document,
        field: 'archiveSpaceUri_ssi',
        value: '/repositories/11/archival_objects/21463'
      }
    end
    context 'with a valid aspace link' do
      around do |example|
        original_value = ENV["ARCHIVES_SPACE_BASE_URL"]
        ENV["ARCHIVES_SPACE_BASE_URL"] = "http://testaspace.base.url/"
        example.run
        ENV["ARCHIVES_SPACE_BASE_URL"] = original_value
      end
      it 'has a valid aspace link' do
        # rubocop:disable Layout/LineLength
        aspace_test_link = helper.aspace_link(args)
        expect(aspace_test_link).to match "<a target=\"_blank\" rel=\"noopener\" href=\"http://testaspace.base.url/repositories/11/archival_objects/21463\">View item information in Archives at Yale<img id=\"popup_window\" alt=\"pop up window\" src=\"/assets/YULPopUpWindow-1c59edaa31bd75f4397080dd0d8ec793700944190826143cf2db06a08fd09ed4.png\" /></a>"
        # rubocop:enable Layout/LineLength
      end
    end
    context "with out environment variable set" do
      around do |example|
        original_value = ENV["ARCHIVES_SPACE_BASE_URL"]
        ENV["ARCHIVES_SPACE_BASE_URL"] = nil
        example.run
        ENV["ARCHIVES_SPACE_BASE_URL"] = original_value
      end
      it 'has a valid aspace link with default url' do
        # rubocop:disable Layout/LineLength
        aspace_test_link = helper.aspace_link(args)
        expect(aspace_test_link).to match "<a target=\"_blank\" rel=\"noopener\" href=\"https://archives.yale.edu/repositories/11/archival_objects/21463\">View item information in Archives at Yale<img id=\"popup_window\" alt=\"pop up window\" src=\"/assets/YULPopUpWindow-1c59edaa31bd75f4397080dd0d8ec793700944190826143cf2db06a08fd09ed4.png\" /></a>"
        # rubocop:enable Layout/LineLength
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

  describe '#join_as_paragraphs' do
    it 'returns multiple items in paragraphs' do
      expect(helper.join_as_paragraphs({ value: %w[Test1 Test2 Test3] })).to eq '<p>Test1</p><p>Test2</p><p>Test3</p>'
    end

    it 'returns one item in paragraph' do
      expect(helper.join_as_paragraphs({ value: %w[Test1] })).to eq '<p>Test1</p>'
    end

    it 'returns nil with nil value' do
      expect(helper.join_as_paragraphs({ value: nil })).to be_nil
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
    context 'with a sensitive materials record' do
      let(:sensitive_materials_document) do
        SolrDocument.new(id: 'test',
                         visibility_ssi: 'Public',
                         sensitive_materials_ssi: 'Yes',
                         oid_ssi: ['2055095'],
                         thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
      end
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end

      it 'returns placeholder with alt text for sensitive materials object' do
        placeholder_image = "/assets/access-image-v2-"
        alt_text = "Access Available within Digital Collections"
        expect(helper.render_thumbnail(sensitive_materials_document, {})).to include(alt_text, placeholder_image)
        expect(helper.render_thumbnail(sensitive_materials_document,
{})).to match("<img alt=\"Access Available within Digital Collections\" src=\"/assets/access-image-v2-f946f99ee0c358bbe16cf8223372b6091680dc48b5082b591eabafdbd7eeb8bd.png\" />")
      end
    end
    context 'with public record and oid with images' do
      let(:valid_document) do
        SolrDocument.new(id: 'test',
                         visibility_ssi: 'Public',
                         oid_ssi: ['2055095'],
                         thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
      end
      let(:non_valid_document) { SolrDocument.new(id: 'test', visibility_ssi: 'Public', oid_ssi: ['9999999999999999']) }
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end
      it 'returns an image_tag for oids that have images' do
        expect(helper.render_thumbnail(valid_document, { alt: "" })).to match "<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg\" />"
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
          thumbnail_path_ss: "http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg"
        )
      end
      before do
        stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg")
          .to_return(status: 200, body: File.open("spec/fixtures/images/Sun.png").read, headers: { "Content-Type" => /image\/.+/ })
      end

      it 'returns placeholder with alt text when logged out' do
        placeholder_image = "/assets/placeholder_restricted-"
        alt_text = "Access Available on YALE network only due to copyright or other restrictions. OFF-SITE? Log in with NetID"
        expect(helper.render_thumbnail(yale_only_document, {})).to include(alt_text, placeholder_image)
      end

      it 'returns image when logged in with valid netid' do
        user = FactoryBot.create(:user, netid: 'net_id')
        sign_in(user) # sign_in so user_signed_in? works in method

        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img [^>]* src=\"http://localhost:8182/iiif/2/1234822/full/#{thumbnail_size}/0/default.jpg\" />")
      end

      # rubocop:disable Layout/LineLength
      it 'user cannot access YCO without a netid' do
        user = FactoryBot.create(:user, netid: nil)
        sign_in(user)
        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img alt=\"Access Available on YALE network only due to copyright or other restrictions. OFF-SITE? Log in with NetID\" src=\"/assets/placeholder_restricted-4d0037c54ed3900f4feaf705e801f4c980164e45ee556f60065c39b4bd4af345.png\" />")
      end
      # rubocop:enable Layout/LineLength

      it 'has lazy loading for the thumbnail image' do
        user = FactoryBot.create(:user, netid: 'net_id')
        sign_in(user)

        expect(helper.render_thumbnail(yale_only_document, {})).to match("<img[^>]* loading=\"lazy\"")
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
        context 'with a date range facet applied' do
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
