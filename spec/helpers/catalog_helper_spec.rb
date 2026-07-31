# frozen_string_literal: true
require 'rails_helper'

RSpec.describe CatalogHelper, helper: true do
  describe '#change_iiif_image_size' do
    let(:iiif_url) { 'https://collections.library.yale.edu/iiif/2/17120080/full/!200,200/0/default.jpg' }

    it 'replaces the size segment of a iiif url' do
      expect(helper.change_iiif_image_size(iiif_url, '!1200,630')).to eq(
        'https://collections.library.yale.edu/iiif/2/17120080/full/!1200,630/0/default.jpg'
      )
    end

    it 'returns nil for a missing url' do
      expect(helper.change_iiif_image_size(nil, '!1200,630')).to be_nil
    end

    it 'returns nil for a javascript: value rather than raising' do
      expect(helper.change_iiif_image_size('javascript:window.__xss=true', '!1200,630')).to be_nil
    end

    it 'returns nil for an unparseable value rather than raising' do
      expect(helper.change_iiif_image_size('http://[not a uri', '!1200,630')).to be_nil
    end

    it 'returns nil for plain text rather than raising' do
      expect(helper.change_iiif_image_size('this is not a url', '!1200,630')).to be_nil
    end
  end
end
