# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogController, type: :controller do
  describe 'facets' do
    let(:facets) do
      controller
        .blacklight_config
    end

    describe 'search fields' do
      let(:search_fields) { controller.blacklight_config.search_fields.keys }

      let(:expected_search_fields) do
        ['all_fields', 'author_tsim', 'orbisBibId_ssim', 'subjectName_ssim', 'title_tsim']
      end

      it { expect(search_fields).to contain_exactly(*expected_search_fields) }
    end
  end
end
