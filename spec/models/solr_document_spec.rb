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

  describe "#to_oai_mods" do
    let(:xml) { Nokogiri::XML(solr_document.to_oai_mods).tap(&:remove_namespaces!) }

    def related_item_href(display_label)
      xml.xpath("//relatedItem[@displayLabel='#{display_label}']").attr("href")&.text
    end

    context "with permitted url schemes" do
      let(:solr_document) do
        described_class.new(WORK_WITH_PUBLIC_VISIBILITY.merge(
                              findingAid_ssim: ['https://archives.yale.edu/repositories/11/resources/1234'],
                              url_suppl_ssim: ['https://collections.library.yale.edu/catalog/111']
                            ))
      end

      it "keeps the finding aid href" do
        expect(related_item_href('Finding Aid')).to eq('https://archives.yale.edu/repositories/11/resources/1234')
      end

      it "keeps the related resource href" do
        expect(related_item_href('Related Resource')).to eq('https://collections.library.yale.edu/catalog/111')
      end
    end

    context "with unpermitted url schemes" do
      let(:solr_document) do
        described_class.new(WORK_WITH_PUBLIC_VISIBILITY.merge(
                              findingAid_ssim: ['javascript:window.__xss=true'],
                              url_suppl_ssim: ['//collections.library.yale.edu/catalog/222']
                            ))
      end

      it "omits the finding aid href" do
        expect(related_item_href('Finding Aid')).to be_nil
      end

      it "omits the related resource href" do
        expect(related_item_href('Related Resource')).to be_nil
      end

      it "does not emit the unpermitted value anywhere in the document" do
        expect(solr_document.to_oai_mods).not_to include('javascript:')
      end
    end

    context "with partOf_tesim, which carries a label rather than a url" do
      let(:solr_document) { described_class.new(WORK_WITH_PUBLIC_VISIBILITY) }

      it "passes the label through without url filtering" do
        expect(related_item_href('Related Exhibition or Resource')).to eq(WORK_WITH_PUBLIC_VISIBILITY[:partOf_tesim].first)
      end
    end

    context "with an unpermitted thumbnail path" do
      let(:solr_document) do
        described_class.new(WORK_WITH_PUBLIC_VISIBILITY.merge(thumbnail_path_ss: 'javascript:window.__xss=true'))
      end

      it "omits the preview url" do
        expect(xml.xpath("//url[@access='preview']").attr("href")&.text).to be_nil
      end
    end
  end
end
