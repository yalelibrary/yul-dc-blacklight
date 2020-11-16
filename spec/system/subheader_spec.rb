# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User Subheader', type: :system, js: true, style: true, clean: true do
  context "User logged out" do
    before do
      visit '/catalog'
    end
    it 'has css' do
      expect(page).to have_css '.user-subheader'
      expect(page).to have_css '.user-subheader-title'
      # expect(page).not_to have_css '.user-subheader-options'
      # expect(page).not_to have_css '.user-subheader-current-user'
      # expect(page).not_to have_css '.user-subheader-logout '
      # expect(page).not_to have_css '.user-subheader-logout a'
      # expect(page).not_to have_css '.logout-logo '
      # expect(page).not_to have_css '.user-logo'
    end

    it 'does not have logout button' do
      expect(page).not_to have_content('Logout')
    end
  end
  context "User logged in" do
    before do
      user = FactoryBot.create(:user)
      login_as(user, scope: :user, provider: :cas)
      visit '/catalog'
    end

    it 'has css' do
      expect(page).to have_css '.user-subheader'
      expect(page).to have_css '.user-subheader-title'
      # expect(page).to have_css '.user-subheader-options'
      # expect(page).to have_css '.user-subheader-current-user'
      # expect(page).to have_css '.user-subheader-logout '
      # expect(page).to have_css '.user-subheader-logout a'
      # expect(page).to have_css '.logout-logo '
      # expect(page).to have_css '.user-logo'
    end

    # it 'signs user out on "Logout"' do
    #   expect(page).to have_link("Logout")
    #   click_on "Logout"

    #   expect(page).to have_content "Signed out successfully."
    # end
  end
end
