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
      oid_ssi: '2055095',
      visibility_ssi: 'Public'
    }
  end
  let(:document_yale_only_image) do
    {
      id: 'test_record_2',
      oid_ssi: '2107188',
      visibility_ssi: 'Yale Community Only'
    }
  end
  let(:document_without_image) do
    {
      id: 'test_record_3',
      oid_ssi: '',
      visibility_ssi: 'Public'
    }
  end

  context 'public records with images', style: true do
    it 'displays thumbnail for oids with images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_xpath("//img[@src = 'https://collections-test.curationexperts.com/iiif/2/1234822/full/!200,200/0/default.jpg']")
    end

    it 'displays the image_not_found.png for records without images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_css("img[src ^= '/assets/image_not_found']")
    end
  end

  describe 'Yale community only records', style: true do
    context 'as a logged out user' do
      it 'displays the placeholder_restricted.png' do
        visit '?q=&search_field=all_fields'
        expect(page).to have_css("img[src ^= '/assets/placeholder_restricted']")
      end

      it 'displays yale only restricted messaging' do
        visit root_path
        visit '?q=&search_field=all_fields'
        click_link 'test_record_2'

        expect(page).to have_content('The digital version of this work is restricted to the Yale Community.')
        expect(page).to have_content('Please login using your Yale NetID or contact library staff to inquire about access to a physical copy.')
      end
    end

    context 'as a logged in user' do
      it 'displays the image', style: true do
        user = FactoryBot.create(:user)
        login_as(user, scope: :user)

        visit '?q=&search_field=all_fields'
        expect(page).to have_xpath("//img[@src = 'https://collections-test.curationexperts.com/iiif/2/1329643/full/!200,200/0/default.jpg']")
      end

      it 'does not display yale only restricted messaging' do
        user = FactoryBot.create(:user)
        login_as(user, scope: :user)

        visit root_path
        visit '?q=&search_field=all_fields'
        click_link 'test_record_2'

        expect(page).not_to have_content('The digital version of this work is restricted to the Yale Community.')
        expect(page).not_to have_content('Please login using your Yale NetID or contact library staff to inquire about access to a physical copy.')
      end
    end
  end
end
