# frozen_string_literal: true
# Helper methods for the advanced search form
module AdvancedHelper
  include BlacklightAdvancedSearch::AdvancedHelperBehavior
  # Overrides method in BlacklightAdvancedSearch::AdvancedHelperBehavior in order to include
  # Aria describedby on select tag
  def select_menu_for_field_operator
    options = {
      t('blacklight_advanced_search.all') => 'AND',
      t('blacklight_advanced_search.any') => 'OR'
    }.sort

    select_tag(:op, options_for_select(options, params[:op]), class: 'input-small', aria: { describedby: 'advanced-help' })
  end
end
