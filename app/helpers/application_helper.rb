# frozen_string_literal: true

module ApplicationHelper
  def login_return_path(path)
    return nil if path.blank?
    return nil unless path.start_with?('/')
    return nil if path.start_with?('//', '/\\')
    path
  end

  # The skip link targets #q, which only exists on pages that render the search bar
  def display_skip_to_search?
    return false if current_page?('/advanced')
    return false if @document.present? && current_page?("/catalog/#{@document[:id]}/request_form")
    true
  end
end
