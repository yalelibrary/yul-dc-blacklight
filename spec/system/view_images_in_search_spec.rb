# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays images', type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([document_with_image,
              document_without_image,
              document_yale_only_image])
    solr.commit
  end
  let(:document_with_image) do
    {
      id: 'test_record_1',
      oid_ssim: ['2055095'],
      visibility_ssi: 'Public'
    }
  end
  let(:document_yale_only_image) do
    {
      id: 'test_record_2',
      oid_ssim: ['2107188'],
      visibility_ssi: 'Yale Community Only'
    }
  end
  let(:document_without_image) do
    {
      id: 'test_record_3',
      oid_ssim: [''],
      visibility_ssi: 'Public'
    }
  end

  context 'public records with images' do
    it 'displays thumbnail for oids with images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_xpath("//img[@src = 'https://collections-test.curationexperts.com/iiif/2/1234822/full/!200,200/0/default.jpg']")
    end

    xit 'displays the image_not_found.png for records without images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_xpath("//img[@src = 'path-to-image-not-found.png']")
    end
  end

  context 'Yale community only records' do
    it 'displays the placeholder_restricted.png when logged out' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_css("img[src ^= '/assets/placeholder_restricted']")
    end
    it 'displays the image when logged in' do
      user = FactoryBot.create(:user)
      login_as(user, scope: :user)

      visit '?q=&search_field=all_fields'
      expect(page).to have_xpath("//img[@src = 'https://collections-test.curationexperts.com/iiif/2/1329643/full/!200,200/0/default.jpg']")
    end
  end
end
