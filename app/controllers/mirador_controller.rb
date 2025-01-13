# frozen_string_literal: true
class MiradorController < ApplicationController
  include BlacklightHelper

  # Allows Mirador to use inline JS to open viewer in new tab
  content_security_policy(only: :show) do |policy|
    policy.script_src_attr  :self, :unsafe_inline, 'siteimproveanalytics.com www.googletagmanager.com'
    policy.script_src_elem  :self, :unsafe_inline, 'siteimproveanalytics.com www.googletagmanager.com'    # policy.style_src :self, :unsafe_inline
    policy.style_src_attr :self, :unsafe_inline
    policy.style_src_elem :self, :unsafe_inline
  end

  def show
    @oid = number_or_nil params[:oid]
    @manifest = @oid ? manifest_url(@oid) : nil
    render layout: false
  end

  def number_or_nil(string)
    Integer(string || '')
  rescue ArgumentError
    nil
  end
end
