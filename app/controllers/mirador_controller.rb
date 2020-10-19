class MiradorController < ApplicationController

  def show
    @oid = params[:oid]
    render layout: false
  end

end
