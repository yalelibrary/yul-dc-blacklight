# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User Authentication', type: :system, js: false, clean: true do
  context 'as a guest user' do
    it 'guest can register account' do
      visit root_path
      click_on "Login"
      click_on "Sign up"

      # fill in account details
      within('#new_user') do
        fill_in 'user_email', with: 'test@gmail.com'

        fill_in 'user_password', with: 'password'
        fill_in 'user_password_confirmation', with: 'password'
      end

      click_on 'Sign up'

      expect(page).to have_content('Welcome! You have signed up successfully.')
    end
    it 'guest can sign in to an already made account' do
      user = FactoryBot.create(:user)
      visit root_path
      click_on "Login"

      within('#new_user') do
        fill_in 'user_email', with: user.email
        fill_in 'user_password', with: user.password
      end
      click_on 'Log in'

      expect(page).to have_content('Signed in successfully.')
      expect(page).to have_content(user.email)
    end
  end
  context 'as a logged in user', js: true do
    before do
      solr = Blacklight.default_index.connection
      solr.add([{ id: 1, title_tsim: 'bookmark me', visibility_ssi: 'Public' }])
      solr.commit
    end
    it 'bookmark will persist after logging-out' do
      user = FactoryBot.create(:user)
      login_as(user, scope: :user)

      visit '/catalog/1'
      check 'Bookmark'
      click_on 'Bookmarks'
      logout(:user)
      login_as(user, scope: :user)

      expect(page).to have_content 'bookmark me'
    end
  end
end
