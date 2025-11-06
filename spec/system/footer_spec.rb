# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'footer', type: :system do
  before do
    visit '/'
  end

  it 'has css' do
    expect(page).to have_css '.section-footer'
    expect(page).to have_css '.footer-logo'
    expect(page).to have_css '.footer-socmedia'
    expect(page).to have_css '.footer-socmedia img'
    expect(page).to have_css '.footer-navigation-links'
    expect(page).to have_css '.footer-navigation-links a'
    expect(page).to have_css '.footer-bottom-links'
    expect(page).to have_css '.footer-bottom-links a'
    expect(page).to have_css '.footer-copyright'
  end

  it 'has links' do
    expect(page).to have_link('Ask Yale Library', href: 'https://ask.library.yale.edu/')
    expect(page).to have_link('My Library Accounts', href: '/my-library-accounts')
    expect(page).to have_link('Subscribe to our Newsletter', href: 'https://subscribe.yale.edu/browse?area=a0df40000006XkNAAU')
    url = page.current_url.gsub("&", "%26")
    expect(page).to have_link('Feedback', href: "http://web.library.yale.edu/form/findit-feedback?findITURL=#{url}")
    expect(page).to have_link('Accessibility', href: 'https://library.yale.edu/accessibility')
    expect(page).to have_link('Giving', href: 'https://library.yale.edu/giving')
    expect(page).to have_link('Privacy and Data Use', href: 'https://library.yale.edu/about-us/about/library-policies/privacy-and-data-use')
    expect(page).to have_link('Library Staff Hub', href: 'https://yaleedu.sharepoint.com/sites/YLHUB/SitePages/Home.aspx?spStartSource=spappbar')
    expect(page).to have_link(nil, href: 'https://www.facebook.com/YaleLibrary')
    expect(page).to have_link(nil, href: 'https://www.instagram.com/yalelibrary')
    expect(page).to have_link(nil, href: 'http://www.youtube.com/yaleuniversitylibrary')
    expect(page).to have_link(nil, href: 'http://www.yale.edu')
  end

  it 'has expected Yale log branding' do
    expect(page.find('.navbar-logo')['//app/images/yul_log/'])
  end

  it 'has expected social media icons images' do
    expect(page.html).to include('<img id="facebook" alt="Yale Library Facebook" src="/assets/soc_media/icon_facebook-')
    expect(page.html).to include('<img id="instagram" alt="Yale Library Instagram" src="/assets/soc_media/icon_instagram-')
    expect(page.html).to include('<img id="youtube" alt="Yale Library Youtube" src="/assets/soc_media/youtube_icon-')
  end
end
