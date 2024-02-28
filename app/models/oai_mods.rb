# frozen_string_literal: true

class OaiMods < OAI::Provider::Metadata::Format
  def initialize
    super
    @prefix = 'oai_mods'
    @element_namespace = 'mods'
    @namespace = 'http://www.loc.gov/mods/v3'
    @schema = 'https://www.loc.gov/standards/mods/v3/mods-3-7.xsd'
  end

  def header_specification
    {
    }
  end
end
