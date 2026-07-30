# frozen_string_literal: true

module ApplicationHelper
  def login_return_path(path)
    return nil if path.blank?
    return nil unless path.start_with?('/')
    return nil if path.start_with?('//', '/\\')
    path
  end
end
