# frozen_string_literal: true

RSpec.describe 'Sitemap Show', type: :feature do
  before do
    solr = Blacklight.default_index.connection
    solr.add([test_record_0, test_record_1, test_record_2, test_record_3, test_record_4])
    solr.commit
  end

  let(:test_record_0) do
    {
      id: '111',
      subtitle_tesim: "He's Handsome",
      creator_tesim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/211',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/211',
      published_ssim: "1997",
      hashed_id_ssi: '082c8d1619ad8176d665453cfb2e55f0',
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      timestamp: "2021-04-05T17:43:23.382Z",
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      thumbnail_path_ss: "http://localhost:8182/iiif/2/10962176/full/!200,200/0/default.jpg",
      visibility_ssi: 'Public',
      year_isim: (600..1050).to_a
    }
  end

  let(:test_record_1) do
    {
      id: '211',
      subtitle_tesim: "He's Handsome",
      creator_tesim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/211',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/211',
      published_ssim: "1997",
      hashed_id_ssi: '182c8d1619ad8176d65453cfb2e776f0',
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      timestamp: "2021-04-05T17:43:23.382Z",
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      thumbnail_path_ss: "http://localhost:8182/iiif/2/10962124/full/!200,200/0/default.jpg",
      year_isim: (1920..2000).to_a
    }
  end

  let(:test_record_2) do
    {
      id: '311',
      subtitle_tesim: "He's Dan",
      creator_tesim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/311',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/311',
      published_ssim: "1997",
      hashed_id_ssi: '282c8d1619ad8176d65453cfb2e776f0',
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      timestamp: "2021-04-05T17:43:23.382Z",
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Public',
      thumbnail_path_ss: "http://localhost:8182/iiif/2/10962124/full/!200,200/0/default.jpg",
      year_isim: [1900]
    }
  end

  let(:test_record_3) do
    {
      id: '411',
      subtitle_tesim: "He's Handsome Dan",
      creator_tesim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/411',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/411',
      published_ssim: "1997",
      hashed_id_ssi: '082c8d1619ad8176d665453cfb2e55f0',
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      timestamp: "2021-04-05T17:43:23.382Z",
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Yale Community Only',
      thumbnail_path_ss: "http://localhost:8182/iiif/2/10962334/full/!200,200/0/default.jpg",
      year_isim: [2020, 2021]
    }
  end

  let(:test_record_4) do
    {
      id: '511',
      subtitle_tesim: "He's Handsome Dan",
      creator_tesim: 'Eric & Frederick',
      format: 'three dimensional object',
      url_fulltext_ssim: 'http://0.0.0.0:3000/catalog/411',
      url_suppl_ssim: 'http://0.0.0.0:3000/catalog/411',
      published_ssim: "1997",
      hashed_id_ssi: '082c8d1619ad8176d665453cfb2e55f0',
      language_ssim: ['en', 'eng', 'zz'],
      isbn_ssim: '2321321389',
      timestamp: "2021-04-05T17:43:23.382Z",
      description_tesim: "Handsome Dan is a bulldog who serves as Yale Univeristy's mascot.",
      visibility_ssi: 'Private',
      thumbnail_path_ss: "http://localhost:8182/iiif/2/10962664/full/!200,200/0/default.jpg",
      year_isim: [2020, 2021]
    }
  end
  it 'renders XML with a root element that leads with a hash of 2' do
    visit blacklight_dynamic_sitemap.sitemap_path('1')
    expect(page).to have_xpath('//urlset')
  end
  it 'renders elements with a hash that leads with 1' do
    visit blacklight_dynamic_sitemap.sitemap_path('1')
    expect(page).to have_xpath('//url', count: 1)
  end
  it 'renders XML with a root element that leads with a hash of 1' do
     visit blacklight_dynamic_sitemap.sitemap_path('0')
    expect(page).to have_xpath('//urlset')
  end
  it 'renders elements with a hash that leads with 1' do
    visit blacklight_dynamic_sitemap.sitemap_path('0')
    expect(page).to have_xpath('//url', count: 2)
  end
  it 'does render a thumbnail for public images' do
    visit blacklight_dynamic_sitemap.sitemap_path('2')
    expect(page.body).to include('<image:loc>http://localhost:8182/iiif/2/10962124/full/!200,200/0/default.jpg</image:loc>')
  end
  it 'does not render a thumbnail for non-public images' do
    visit blacklight_dynamic_sitemap.sitemap_path('0')
    expect(page).not_to have_content('http://localhost:8182/iiif/2/10962334/full/!200,200/0/default.jpg')
  end
  it 'does not display a private record' do
    visit blacklight_dynamic_sitemap.sitemap_path('0')
    expect(page).not_to have_content '511'
  end
end
