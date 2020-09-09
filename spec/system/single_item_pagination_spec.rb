# frozen_string_literal: true
RSpec.feature "Single Item Pagination", type: :system, clean: true, js: true do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record,
              same_call_record,
              diff_call_record])
    solr.commit
    visit root_path
    visit '?search_field=all_fields&q='
  end

  let(:same_call_record) do
    {
      id: '222',
      visibility_ssi: 'Public',
      identifierShelfMark_ssim: 'this is the identifier shelf mark'
    }
  end

  let(:diff_call_record) do
    {
      id: '333',
      visibility_ssi: 'Public',
      identifierShelfMark_ssim: 'this is the identifier shelf mark, but different'
    }
  end

  let(:test_record) do
    {
      id: '111',
      visibility_ssi: "Public"
    }
  end

  it 'has expected css' do
    ensure_click_link '111', page

    expect(page).to have_css '.page-links-show'
    expect(page).to have_css '.page-items-show'
    expect(page).to have_css '.page-info-show'
  end

  context "in the first item" do
    it 'does not have "Previous" and should have "Next"' do
      ensure_click_link '111', page

      expect(page).not_to have_link("< Previous")
      expect(page).to have_link("Next >", href: '/catalog/222')
      expect(page).to have_content("1 of 3")
    end
  end

  context "in the second item" do
    it 'has "Previous" and "Next"' do
      ensure_click_link '222', page

      expect(page).to have_link("< Previous", href: '/catalog/111')
      expect(page).to have_link("Next >", href: '/catalog/333')
      expect(page).to have_content("2 of 3")
    end
  end

  context "in the third item" do
    it 'has "Previous", but not "Next"' do
      ensure_click_link '333', page

      expect(page).to have_link("< Previous", href: '/catalog/222')
      expect(page).not_to have_link("Next >")
      expect(page).to have_content("3 of 3")
    end
  end
end
