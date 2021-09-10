# frozen_string_literal: true
module YulBlacklight
  class SearchService < Blacklight::SearchService
    def fetch(id = nil, extra_controller_params = nil)
      extra_controller_params = { fl: @blacklight_config.default_solr_params[:fl] } if extra_controller_params.nil?
      super(id, extra_controller_params)
    end
  end
end
