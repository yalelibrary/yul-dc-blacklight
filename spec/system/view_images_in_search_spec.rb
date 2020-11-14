# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Search results displays images', type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([document_with_image,
              document_without_image,
              document_yale_only_image,
              document_with_broken_image])
    solr.commit
    stub_request(:get, "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg")
      .to_return(status: 200, body: File.open("spec/fixtures/images/small_jpeg.jpeg").read)
  end

  let(:document_with_image) do
    {
      id: 'test_record_1',
      oid_ssi: '2055095',
      visibility_ssi: 'Public',
      thumbnail_path_ss: "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg"
    }
  end
  let(:document_yale_only_image) do
    {
      id: 'test_record_2',
      oid_ssi: '2107188',
      visibility_ssi: 'Yale Community Only',
      thumbnail_path_ss: "http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg"
    }
  end
  let(:document_without_image) do
    {
      id: 'test_record_3',
      oid_ssi: '',
      visibility_ssi: 'Public'
    }
  end
  let(:document_with_broken_image) do
    {
      id: 'test_record_4',
      oid_ssi: '99',
      visibility_ssi: 'Public',
      thumbnail_path_ss: "http://iiif_image:8182/iiif/2/foo"
    }
  end

  context 'public records with images', style: true, js: false do
    it 'displays thumbnail for oids with images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_xpath("//img[@src = 'http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg']")
    end

    it 'displays the image_not_found.png for records without images' do
      visit '?q=&search_field=all_fields'
      expect(page).to have_css("img[src ^= '/assets/image_not_found']")
    end
  end

  context 'public records with broken images', style: true do
    it 'displays the image_not_found_png for records with broken images' do
      visit "?q=#{document_with_broken_image[:oid_ssi]}&search_field=oid_ssi"
      expect(page.html).to match('/assets/image_not_found')
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
      it 'displays the image', style: true, js: false do
        user = FactoryBot.create(:user)
        login_as(user, scope: :user)

        visit '?q=&search_field=all_fields'
        expect(page).to have_xpath("//img[@src = 'http://iiif_image:8182/iiif/2/1234822/full/!200,200/0/default.jpg']")
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
