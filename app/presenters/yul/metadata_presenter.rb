# frozen_string_literal: true

module Yul
  class MetadataPresenter
    attr_reader :document, :config

    def initialize(document:, section:)
      @document = document.detect { |_i| Blacklight::ShowPresenter }[2].instance_variable_get('@document').to_h
      @config = YAML.safe_load(File.open(Rails.root.join('config', 'metadata', "#{section}_metadata.yml")))
    end

    def terms
      @document.slice(*@config.keys)
    end
  end
end
