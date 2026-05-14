# frozen_string_literal: true
class MiradorController < ApplicationController
  include BlacklightHelper

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
