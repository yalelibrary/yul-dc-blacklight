# frozen_string_literal: true

module Yul
  module Gallery
    # Gallery view entry. Uses the same title as the list view (index_title),so long titles are truncated
    class DocumentComponent < Blacklight::Gallery::DocumentComponent
      def before_render
        with_title(helpers.index_title(@document)) unless title
        super
      end
    end
  end
end
