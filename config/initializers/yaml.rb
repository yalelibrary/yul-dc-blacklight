# frozen_string_literal: true
module YAML
  class << self
    alias load unsafe_load if YAML.respond_to? :unsafe_load
  end
end
