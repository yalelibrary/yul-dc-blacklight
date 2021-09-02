# frozen_string_literal: true
RSpec.feature "Single Item Pagination", type: :system, clean: true, js: true do
  before do
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/11/11/111.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/22/22/222.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)
    stub_request(:get, 'https://yul-dc-development-samples.s3.amazonaws.com/manifests/33/33/333.json')
      .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2041002.json')).read)

    solr = Blacklight.default_index.connection
    solr.add([test_record,
              same_call_record,
              diff_call_record])
    solr.commit
    visit search_catalog_path
    visit '/catalog?search_field=all_fields&q='
  end

  let(:same_call_record) do
    {
      id: '222',
      visibility_ssi: 'Public',
      callNumber_ssim: 'this is the call number'
    }
  end

  let(:diff_call_record) do
    {
      id: '333',
      visibility_ssi: 'Public',
      callNumber_ssim: 'this is the call number, but different'
    }
  end

  let(:test_record) do
    {
      id: '111',
      visibility_ssi: "Public",
      callNumber_ssim: 'this is the call number, but moderately different'
    }
  end

  it 'has expected css' do
    click_link '111'

    expect(page).to have_css '.page-links-show'
    expect(page).to have_css '.page-items-show'
    expect(page).to have_css '.page-info-show'
  end

  context "in the first item" do
    it 'does not have "Previous" and should have "Next"' do
      click_link '111'

      expect(page).not_to have_link("< Previous")
      expect(page).to have_link("Next >", href: '/catalog/222')
      expect(page).to have_content("1 of 3")
    end
  end

  context "in the second item" do
    it 'has "Previous" and "Next"' do
      click_link '222'

      expect(page).to have_link("< Previous", href: '/catalog/111')
      expect(page).to have_link("Next >", href: '/catalog/333')
      expect(page).to have_content("2 of 3")
    end
  end

  context "in the third item" do
    it 'has "Previous", but not "Next"' do
      click_link '333'

      expect(page).to have_link("< Previous", href: '/catalog/222')
      expect(page).not_to have_link("Next >")
      expect(page).to have_content("3 of 3")
    end
  end
end
