# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument, type: :model do
  context "with public work" do
    let(:solr_document) { described_class.new(WORK_WITH_PUBLIC_VISIBILITY) }
    it "creates valid schema.org metadata" do
      schema = solr_document.to_schema_json_ld

      expect(schema[:@context]).to eq('https://schema.org/')
      expect(schema[:@type]).to eq('CreativeWork')

      expect(schema[:name]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:title_tesim])
      expect(schema[:alternateName]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:alternativeTitle_tesim])
      expect(schema[:description]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:description_tesim])
      expect(schema[:url]).to eq("https://collections.library.yale.edu/catalog/#{WORK_WITH_PUBLIC_VISIBILITY[:id]}")
      expect(schema[:genre]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:genre_ssim])
      expect(schema[:materialExtent]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:extent_ssim])
      expect(schema[:temporal]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:date_ssim])
      expect(schema[:thumbnailUrl]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:thumbnail_path_ss])

      # work because the WORK_WITH_PUBLIC_VISIBILITY record has a value for each of these fields.
      abouts = schema[:about]
      all_expected_abouts = WORK_WITH_PUBLIC_VISIBILITY[:subjectName_ssim] + WORK_WITH_PUBLIC_VISIBILITY[:subjectTopic_ssim] + WORK_WITH_PUBLIC_VISIBILITY[:subjectGeographic_ssim]
      all_expected_abouts.each_with_index do |expected_about, ix|
        expect(abouts[ix][:name]).to eq(expected_about)
        expect(abouts[ix][:@type]).to eq("Thing")
      end
    end
  end

  context "with yale only work" do
    let(:solr_document) { described_class.new(WORK_WITH_YALE_ONLY_VISIBILITY) }
    it "does not include thumbnail" do
      schema = solr_document.to_schema_json_ld
      expect(schema[:thumbnailUrl]).to be_nil
    end
  end

  # Mirrors the `<a href>` allowlist BlacklightHelper#sanitize_values uses for display.
  describe "sanitizing schema.org metadata" do
    def schema_for(fields)
      described_class.new({ id: '1234', visibility_ssi: 'Public' }.merge(fields)).to_schema_json_ld
    end

    # url and thumbnailUrl are generated rather than copied, so they are excluded.
    def strings_in(value)
      case value
      when Hash then value.except(:url, :thumbnailUrl).values.flat_map { |v| strings_in(v) }
      when Array then value.flat_map { |v| strings_in(v) }
      when String then [value]
      else []
      end
    end

    it "strips markup from string values" do
      schema = schema_for(description_tesim: ["A <em>very</em> old <strong>map</strong>"])
      expect(schema[:description]).to eq(["A very old map"])
    end

    it "sanitizes every text field it emits" do
      schema = schema_for(
        title_tesim: ["<em>Title</em>"],
        alternativeTitle_tesim: ["<em>Alt</em>"],
        description_tesim: ["<em>Desc</em>"],
        genre_ssim: ["<em>Genre</em>"],
        extent_ssim: ["<em>Extent</em>"],
        date_ssim: ["<em>Date</em>"]
      )
      expect(schema[:name]).to eq(["Title"])
      expect(schema[:alternateName]).to eq(["Alt"])
      expect(schema[:description]).to eq(["Desc"])
      expect(schema[:genre]).to eq(["Genre"])
      expect(schema[:materialExtent]).to eq(["Extent"])
      expect(schema[:temporal]).to eq(["Date"])
    end

    # Every document value arrives carrying markup, so a field added to
    # to_schema_json_ld without sanitizing shows up here rather than passing silently.
    it "sanitizes any value it copies out of the document" do
      document = described_class.new(WORK_WITH_PUBLIC_VISIBILITY.to_h do |key, value|
        next [key, value] if %i[id visibility_ssi thumbnail_path_ss].include?(key.to_sym)

        [key, Array.wrap(value).map { |v| v.is_a?(String) ? "<em>#{v}</em>" : v }]
      end)

      copied = strings_in(document.to_schema_json_ld)
      expect(copied).not_to be_empty
      expect(copied).to all(satisfy { |v| !v.include?("<") })
    end

    it "strips markup from subject values nested inside about entries" do
      schema = schema_for(subjectTopic_ssim: ["Cats <em>and</em> dogs"])
      expect(schema[:about].first[:name]).to eq("Cats and dogs")
    end

    it "sanitizes all three subject fields that feed about" do
      schema = schema_for(
        subjectName_ssim: ["<em>Cockerell, Sydney</em>"],
        subjectTopic_ssim: ["Manuscripts <script>alert(1)</script>"],
        subjectGeographic_ssim: ["<strong>New Haven</strong>"]
      )
      expect(schema[:about].map { |entry| entry[:name] }).to eq(["Cockerell, Sydney", "Manuscripts", "New Haven"])
      expect(schema[:about].map { |entry| entry[:@type] }).to all(eq("Thing"))
    end

    it "removes script elements along with their inner text" do
      schema = schema_for(description_tesim: ["Cats <script>alert(1)</script>"])
      expect(schema[:description]).to eq(["Cats"])
    end

    it "removes style elements along with their inner text" do
      schema = schema_for(description_tesim: ["Map <style>body{display:none}</style>here"])
      expect(schema[:description]).to eq(["Map here"])
    end

    it "removes a script breakout payload entirely" do
      schema = schema_for(title_tesim: ["</script><script>alert(1)</script>"])
      expect(schema[:name]).to eq([""])
    end

    it "removes HTML comments" do
      schema = schema_for(description_tesim: ["Before <!-- internal note --> after"])
      expect(schema[:description].first).not_to include("internal note")
    end

    it "drops javascript hrefs from anchors it keeps" do
      schema = schema_for(description_tesim: ['<a href="javascript:alert(1)">click</a>'])
      expect(schema[:description]).to eq(["<a>click</a>"])
    end

    it "removes event handler attributes along with the element that carried them" do
      schema = schema_for(description_tesim: ['<img src="x" onerror="alert(1)">caption'])
      expect(schema[:description]).to eq(["caption"])
    end

    it "keeps anchor tags, matching the allowlist the display path uses" do
      schema = schema_for(description_tesim: ['See <a href="http://example.com">the finding aid</a>'])
      expect(schema[:description]).to eq(['See <a href="http://example.com">the finding aid</a>'])
    end

    it "strips disallowed attributes from anchor tags it keeps" do
      schema = schema_for(description_tesim: ['<a href="http://example.com" onclick="alert(1)">a link</a>'])
      expect(schema[:description]).to eq(['<a href="http://example.com">a link</a>'])
    end

    it "leaves plain text values untouched rather than entity encoding them" do
      schema = schema_for(title_tesim: ["Dogs & Cats: an author's \"study\""])
      expect(schema[:name]).to eq(["Dogs & Cats: an author's \"study\""])
    end

    it "leaves generated url fields alone" do
      schema = schema_for(title_tesim: ["A Title"])
      expect(schema[:url]).to eq("https://collections.library.yale.edu/catalog/1234")
    end
  end
end
