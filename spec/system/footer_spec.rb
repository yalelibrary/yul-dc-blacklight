# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'footer', type: :system do
  before do
    visit '/'
  end

  it 'has css' do
    expect(page).to have_css '.footer-container'
    expect(page).to have_css '.footer-logo'
    expect(page).to have_css '.footer-links'
    expect(page).to have_css '.footer-links a'
    expect(page).to have_css '.footer-socmedia'
    expect(page).to have_css '.footer-socmedia img'
    expect(page).to have_css '.branch-name'
  end

  it 'has links' do
    expect(page).to have_link('Search', href: 'http://web.library.yale.edu/gsearch')
    expect(page).to have_link('News', href: 'http://www.library.yale.edu/librarynews')
    expect(page).to have_link('Systems Status', href: 'http://status.library.yale.edu')
    expect(page).to have_link('Privacy Policy', href: 'http://www.yale.edu/privacy.html')
    expect(page).to have_link('Terms', href: 'https://guides.library.yale.edu/about/policies/access')
    expect(page).to have_link('Feedback', href: 'http://web.library.yale.edu/form/findit-feedback?findITURL=http://127.0.0.1/')
    expect(page).to have_link('Data Use', href: 'https://web.library.yale.edu/data-use')
    expect(page).to have_link('Accessibility', href: 'https://usability.yale.edu/web-accessibility/accessibility-yale')
    expect(page).to have_link(nil, href: 'http://yaleuniversity.tumblr.com/')
    expect(page).to have_link(nil, href: 'https://www.instagram.com/yalelibrary')
    expect(page).to have_link(nil, href: 'https://twitter.com/yalelibrary')
    expect(page).to have_link(nil, href: 'https://www.facebook.com/yalelibrary')
  end

  it 'has expected Yale log branding' do
    expect(page.find('.navbar-logo')['//app/images/yul_log/'])
  end

  it 'has expected social media icons images' do
    expect(page.html).to include('<img id="tumblr" src="/assets/soc_media/icon_tumblr-')
    expect(page.html).to include('<img id="instagram" src="/assets/soc_media/icon_instagram-')
    expect(page.html).to include('<img id="twitter" src="/assets/soc_media/icon_twitter-')
    expect(page.html).to include('<img id="facebook" src="/assets/soc_media/icon_facebook-')
  end
end
