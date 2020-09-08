# frozen_string_literal: true
class SearchHistoryController < ApplicationController
  include Blacklight::SearchHistory

  helper BlacklightRangeLimit::ViewHelperOverride
  # helper BlacklightAdvancedSearch::RenderConstraintsOverride
  helper RangeLimitHelper
  helper BlacklightAdvancedSearch::RenderConstraintsOverride
end
