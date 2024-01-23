# frozen_string_literal: true
# override from Blacklight v7.36.2

module Yul
  module System
    class ModalComponent < ViewComponent::Base
      include Blacklight::ContentAreasShim

      renders_one :prefix
      renders_one :header
      renders_one :title
      renders_one :body
      renders_one :footer
    end
  end
end