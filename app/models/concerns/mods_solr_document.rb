# frozen_string_literal: true

module ModsSolrDocument
  extend ActiveSupport::Concern

  def to_oai_mods
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => 'http://www.loc.gov/mods/v3', 'version' => '3.4') do
        xml['mods'].identifier({ type: 'ladybird' }, "oid#{self[:id]}")
        xml['mods'].identifier({ displayLabel: 'Accession Number', type: 'local' }, self[:accessionNumber_ssi]) if self[:accessionNumber_ssi].present?
        xml['mods'].identifier({ displayLabel: 'Barcode', type: 'local' }, self[:orbisBarcode_ssi]) if self[:orbisBarcode_ssi].present?

        xml['mods'].titleInfo do
          self[:title_tesim]&.each { |title| xml['mods'].title title.to_s }
        end
        self[:extent_ssim]&.each { |extent| xml['mods'].extent extent.to_s }
      end
    end
    Nokogiri::XML(builder.to_xml).root.to_xml
  end
end
