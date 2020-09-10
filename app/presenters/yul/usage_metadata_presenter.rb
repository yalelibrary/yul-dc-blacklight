# frozen_string_literal: true
module Yul
  class UsageMetadataPresenter
    attr_reader :document, :config

    def initialize(document:)
      @document = document.detect { |_i| Blacklight::ShowPresenter }[2].instance_variable_get("@document").to_h
      @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata/usage_metadata.yml')))
    end

    def usage_terms
      @document.slice(*@config.keys)
    end
  end
end
