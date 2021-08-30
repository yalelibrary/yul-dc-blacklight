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
      expect(schema[:archivalSort]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:archivalSort_ssi])
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
end
