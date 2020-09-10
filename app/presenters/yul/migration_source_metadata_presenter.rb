# frozen_string_literal: true
module Yul
  class MigrationSourceMetadataPresenter
    attr_reader :document, :config

    def initialize(document:)
      @document = document.detect { |_i| Blacklight::ShowPresenter }[2].instance_variable_get("@document").to_h
      @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata/migration_source_metadata.yml')))
    end

    def migration_source_terms
      @document.slice(*@config.keys)
    end
  end
end
