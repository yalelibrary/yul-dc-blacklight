# frozen_string_literal: true
module Yul
  class KeywordMetadataPresenter
    attr_reader :document, :config

    def initialize(document:)
      @document = document.detect { |i| i = Blacklight::ShowPresenter }[2].instance_variable_get("@document").to_h
      @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata/keyword_metadata.yml')))
    end

    def keyword_terms
      @document.slice(*@config.keys)
    end
  end
end
