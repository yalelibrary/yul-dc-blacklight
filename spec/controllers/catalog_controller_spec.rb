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

      # All of the "config.add_search_field" values in the catalog controller
      let(:expected_search_fields) do
        ['all_fields',
         'all_fields_advanced',
         'creator_tesim',
         'child_oids_ssim',
         'date_fields',
         'genre_fields',
         'identifierShelfMark_tesim',
         'oid_ssi',
         'orbisBibId_ssi',
         'subjectName_ssim',
         'subject_fields',
         'title_tesim']
      end

      it { expect(search_fields).to contain_exactly(*expected_search_fields) }
    end
  end
end
