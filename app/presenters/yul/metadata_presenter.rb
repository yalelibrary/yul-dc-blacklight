# frozen_string_literal: true

module Yul
  class MetadataPresenter < Blacklight::ShowPresenter
    attr_reader :document, :config

    def initialize(document, view_context, configuration = view_context.blacklight_config)
      @metadata_sections = %w[description subjects,_formats,_and_genres collection_information access_and_usage_rights identifiers]
      super
    end

    def metadata_fields_to_render(metadata_section = nil)
      return fields_to_render unless @metadata_sections.include? metadata_section
      if block_given?
        fields.each do |name, field_config|
          field_presenter = field_presenter(field_config)
          next unless field_presenter.render_field? && field_presenter.any? && field_config[:metadata].eql?(metadata_section)
          yield name, field_config, field_presenter
        end
      else
        to_enum(:fields_to_render).select do |_name, field_config|
          field_config[:metadata].eql? metadata_section
        end
      end
    end
  end
end
