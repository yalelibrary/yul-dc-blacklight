# frozen_string_literal: true
class MiradorController < ApplicationController
  include BlacklightHelper

  # The per-action CSP override that previously re-asserted :unsafe_inline for
  # script directives has been removed. The Mirador show view's inline init script
  # now carries a CSP nonce (see app/views/mirador/show.html.erb), and the global
  # policy's :unsafe_inline-free script-src directives apply uniformly.

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
