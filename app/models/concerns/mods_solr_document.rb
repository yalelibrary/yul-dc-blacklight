

module ModsSolrDocument
  extend ActiveSupport::Concern

  def to_oai_mods
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.mods('xmlns:mods' => 'http://www.loc.gov/mods/v3', 'version' =>'3.4') {
        xml['mods'].titleInfo {
          self[:title_tesim].each { |title| xml['mods'].title "#{title}" }
          self[:extent_ssim].each { |extent| xml['mods'].extent "#{extent}" }          
        }
      }
    end
    Nokogiri::XML(builder.to_xml).root.to_xml
  end
end