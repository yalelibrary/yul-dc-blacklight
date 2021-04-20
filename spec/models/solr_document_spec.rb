# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolrDocument, type: :model do
  context "with public work" do
    let(:solr_document) { described_class.new(WORK_WITH_PUBLIC_VISIBILITY) }
    it "creates valid schema.org metadata" do
      schema = solr_document.to_schema_json_ld
      expect(schema[:@context]).to eq('https://schema.org/')
      expect(schema[:@type]).to eq('CreativeWork')

      expect(schema[:name]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:title_tesim]&.join(", "))
      expect(schema[:alternateName]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:alternativeTitle_tesim]&.join(", "))
      expect(schema[:description]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:description_tesim]&.join(", "))
      expect(schema[:url]).to eq("https://collections.library.yale.edu/catalog/#{WORK_WITH_PUBLIC_VISIBILITY[:id]}")
      expect(schema[:genre]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:genre_ssim]&.join(", "))
      expect(schema[:materialExtent]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:extent_ssim]&.join(", "))
      expect(schema[:temporal]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:date_ssim]&.join(", "))
      expect(schema[:thumbnailUrl]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:thumbnail_path_ss])

      about = schema[:about]
      expect(about[:name]).to eq(WORK_WITH_PUBLIC_VISIBILITY[:subjectName_ssim]&.join(", "))
      expect(about[:description]).to eq([WORK_WITH_PUBLIC_VISIBILITY[:subjectTopic_ssim]&.join(", "), WORK_WITH_PUBLIC_VISIBILITY[:subjectGeographic_ssim]&.join(", ")].join(", "))
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
