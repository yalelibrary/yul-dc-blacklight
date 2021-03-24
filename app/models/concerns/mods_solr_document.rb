# frozen_string_literal: true

#
module ModsSolrDocument
  extend ActiveSupport::Concern

  # rubocop:disable Metrics/BlockLength,Metrics/MethodLength
  def to_oai_mods
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => 'http://www.loc.gov/mods/v3', 'version' => '3.4') do
        xml['mods'].identifier({ type: 'ladybird' }, "oid#{self[:id]}")
        xml['mods'].identifier({ displayLabel: 'Accession Number', type: 'local' }, self[:accessionNumber_ssi]) if self[:accessionNumber_ssi].present?
        xml['mods'].identifier({ displayLabel: 'Barcode', type: 'local' }, self[:orbisBarcode_ssi]) if self[:orbisBarcode_ssi].present?
        self[:abstract_tesim]&.each { |abstract| xml['mods'].abstract abstract.to_s }
        self[:accessRestrictions_tesim]&.each { |access| xml['mods'].accessCondition access.to_s }
        self[:genre_ssim]&.each { |genre| xml['mods'].genre genre.to_s }
        self[:description_tesim]&.each { |note| xml['mods'].note note.to_s }
        self[:callNumber_ssim]&.each { |classification| xml['mods'].classification classification.to_s }
        self[:repository_ssim]&.each { |note| xml['mods'].note({ type: 'preferred citation' }, note.to_s) }
        self[:caption_tesim]&.each { |note| xml['mods'].note({ displayLabel: 'Caption' }, note.to_s) }
        xml['mods'].note({ displayLabel: 'number' }, self[:number_of_pages_ss]) if self[:number_of_pages_ss].present?
        self[:extentOfDigitization_ssim]&.each { |note| xml['mods'].note({ displayLabel: 'Parts scanned' }, note.to_s) }
        self[:digital_ssim]&.each { |note| xml['mods'].note({ displayLabel: 'Digital' }, note.to_s) }
        if self[:format_tesim].present?
          self[:format_tesim].select { |format| valid_formats.any? { |f| f.include?(format.downcase) } }.each { |type_resource| xml['mods'].typeOfResource type_resource.to_s }
        end
        self[:rights_ssim]&.each { |access_condition| xml['mods'].accessCondition({ type: 'restriction on access' }, access_condition.to_s) }
        if self[:language_ssim]
          xml['mods'].language do
            self[:language_ssim]&.each { |language| xml['mods'].languageTerm(language.to_s) }
          end
        end
        if self[:creatorDisplay_tsim]
          xml['mods'].name do
            self[:creatorDisplay_tsim]&.each { |creator_display| xml['mods'].namePart(creator_display.to_s) }
          end
        end
        xml['mods'].titleInfo do
          self[:title_tesim]&.each { |title| xml['mods'].title title.to_s }
          self[:alternativeTitle_tesim]&.each { |alternative_title| xml['mods'].alternative alternative_title.to_s }
        end
        if self[:extent_ssim]
          xml['mods'].physicalDescription do
            self[:extent_ssim]&.each { |extent| xml['mods'].extent extent.to_s }
          end
        end
        self[:findingAid_ssim]&.each { |finding_aid| xml['mods'].relatedItem({ displayLabel: 'Finding Aid', "xlink:href" => finding_aid }) }
        self[:url_suppl_ssim]&.each { |url_suppl| xml['mods'].relatedItem({ displayLabel: 'Related Resource', "xlink:href" => url_suppl }) }
        self[:partOf_tesim]&.each { |part_of| xml['mods'].relatedItem({ displayLabel: 'Related Exhibition or Resource', "xlink:href" => part_of }) }
      end
    end
    Nokogiri::XML(builder.to_xml).root.to_xml
  end
  # rubocop:enable Metrics/BlockLength,Metrics/MethodLength

  def valid_formats
    ["text",
     "cartographic",
     "notated music",
     "sound recording",
     "sound recording-musical",
     "sound recording-nonmusical",
     "still image", "moving image",
     "three dimensional object",
     "software, multimedia",
     "mixed material"]
  end
end
