# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'header', type: :system do
  before do
    visit '/'
  end

  it 'has expected css' do
    expect(page).to have_css '.bg-dark'
    expect(page).to have_css '.dropdown-menu'
    expect(page).to have_css '.info-header'
    expect(page).to have_css '.nav-link'
    expect(page).to have_css '.navbar-brand'
    expect(page).to have_css '.navbar-logo'
    expect(page).to have_css '.secondary-nav'
    expect(page).to have_css '.secondary-nav a'
  end

  it 'has expected links on the main header' do
    expect(page).to have_link('Ask Yale Library', href: 'http://ask.library.yale.edu/')
    expect(page).to have_link('Reserve Rooms', href: 'https://schedule.yale.edu/')
    expect(page).to have_link('Places to Study', href: 'https://web.library.yale.edu/places/to-study')
    expect(page).to have_link('Yale University Library', href: 'https://library.yale.edu/')
  end

  it 'has expected links in the submenu' do
    expect(page).to have_link('Quicksearch', href: 'http://search.library.yale.edu')
    expect(page).to have_link('Search Library Catalog (Orbis)', href: 'http://orbis.library.yale.edu/vwebv/')
    expect(page).to have_link('Search Law Library Catalog (MORRIS)', href: 'http://morris.law.yale.edu/')
    expect(page).to have_link('Search Borrow Direct', href: 'https://resources.library.yale.edu/cas/borrowdirect.aspx')
    expect(page).to have_link('Search WorldCat', href: 'http://firstsearch.oclc.org/dbname=WorldCat;autho=100157622;FSIP')
    expect(page).to have_link('Search Articles+', href: 'http://yale.summon.serialssolutions.com/')
    expect(page).to have_link('Search Digital Collections', href: 'http://web.library.yale.edu/digital-collections')
    expect(page).to have_link('Search Archives at Yale', href: 'http://archives.yale.edu')
    expect(page).to have_link('Research Guides', href: 'http://guides.library.yale.edu/')
    expect(page).to have_link('Find Databases by Title', href: 'http://search.library.yale.edu/databases')
    expect(page).to have_link('Find eJournals by Title', href: 'http://wa4py6yj8t.search.serialssolutions.com')
    expect(page).to have_link('Guide to Using Special Collections', href: 'http://guides.library.yale.edu/specialcollections')
    expect(page).to have_link('Your Personal Librarian', href: 'https://library.yale.edu/pl')
    expect(page).to have_link('Subject Specialists', href: 'https://library.yale.edu/subject-specialists')
    expect(page).to have_link('Research Support and Workshops', href: 'http://guides.library.yale.edu/research-help')
    expect(page).to have_link('Citation Tools', href: 'http://guides.library.yale.edu/citationmanagement')
    expect(page).to have_link('Get It @ Yale (Borrow Direct, Interlibrary Loan, Scan & Deliver)', href: 'http://guides.library.yale.edu/getit')
    expect(page).to have_link('Course Reserves', href: 'http://guides.library.yale.edu/reserves')
    expect(page).to have_link('Off-Campus Access', href: 'https://guides.library.yale.edu/OffCampusAccess')
    expect(page).to have_link('EliScholar', href: 'http://elischolar.library.yale.edu')
    expect(page).to have_link('OverDrive: Popular Audio and eBooks', href: 'http://yale.lib.overdrive.com/')
    expect(page).to have_link('Bass Media Equipment', href: 'https://reservations.yale.edu/bmec/')
    expect(page).to have_link('Arts Library', href: 'https://web.library.yale.edu/building/haas-family-arts-library')
    expect(page).to have_link('Bass Library', href: 'https://web.library.yale.edu/building/bass-library')
    expect(page).to have_link('Beinecke Library', href: 'https://web.library.yale.edu/building/beinecke-rare-book-library')
    expect(page).to have_link('Classics Library', href: 'https://web.library.yale.edu/building/classics-library')
    expect(page).to have_link('Divinity Library', href: 'https://web.library.yale.edu/building/divinity-library')
    expect(page).to have_link('Film Study Center', href: 'https://library.yale.edu/film')
    expect(page).to have_link('Fortunoff Archive', href: 'http://www.library.yale.edu/testimonies/')
    expect(page).to have_link('Humanities Collections', href: 'https://library.yale.edu/humanities')
    expect(page).to have_link('International Collections', href: 'https://web.library.yale.edu/international-collections')
    expect(page).to have_link('Law Library', href: 'https://web.library.yale.edu/building/lillian-goldman-law-library')
    expect(page).to have_link('Lewis Walpole Library', href: 'https://web.library.yale.edu/building/lewis-walpole-library')
    expect(page).to have_link('Library Collection Services', href: 'https://web.library.yale.edu/sd/dept/library-collection-services-and-operations')
    expect(page).to have_link('Manuscripts & Archives', href: 'https://library.yale.edu/mssa')
    expect(page).to have_link('Map Collection', href: 'http://www.library.yale.edu/maps')
    expect(page).to have_link('Marx Science & Social Science Library', href: 'https://web.library.yale.edu/building/marx-science-and-social-science-library')
    expect(page).to have_link('Mathematics Library', href: 'https://web.library.yale.edu/building/mathematics-library')
    expect(page).to have_link('Medical Library', href: 'https://web.library.yale.edu/building/cushingwhitney-medical-library')
    expect(page).to have_link('Music Library', href: 'https://library.yale.edu/music')
    expect(page).to have_link('Sterling Library', href: 'https://web.library.yale.edu/building/sterling-memorial-library')
    expect(page).to have_link('Yale Center for British Art', href: 'https://web.library.yale.edu/building/yale-center-for-british-art')
    expect(page).to have_link('Library Hours', href: 'https://library.yale.edu/visit-and-study')
    expect(page).to have_link('Departments & Staff', href: ' https://library.yale.edu/staff-directory')
    expect(page).to have_link('Borrowing & Circulation', href: 'http://guides.library.yale.edu/borrow')
    expect(page).to have_link('Services for Persons with Disabilities', href: ' https://web.library.yale.edu/services-persons-disabilities')
    expect(page).to have_link('Copyright Basics', href: 'http://guides.library.yale.edu/copyright-guidance/copyright-basics')
    expect(page).to have_link('Scanning, Printing & Copying', href: 'https://web.library.yale.edu/help/scanning-printing-copying')
    expect(page).to have_link('Computers Wireless', href: 'https://web.library.yale.edu/help/computers-and-wireless')
    expect(page).to have_link('Library Policies', href: 'http://guides.library.yale.edu/about/policies')
    expect(page).to have_link('About the Library', href: 'http://guides.library.yale.edu/about')
    expect(page).to have_link('Giving to the Library', href: 'https://library.yale.edu/development')
    expect(page).to have_link('Purchase Request', href: 'https://ask.library.yale.edu/faq/174852')
    expect(page).to have_link('Working at the Library', href: 'http://guides.library.yale.edu/work')
    expect(page).to have_link('Terms Governing Use of Materials', href: 'https://guides.library.yale.edu/about/policies/access')
  end

  it 'has expected Yale log branding' do
    expect(page.find('.navbar-logo')['//app/images/yul_logo/'])
  end
end
