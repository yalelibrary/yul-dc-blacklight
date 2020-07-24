# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User Authentication', type: :system, js: false, clean: true do
  let(:user) { FactoryBot.create(:user) }

  context 'an unauthenticated user' do
    it 'gets the omniauth redirect endpoing for Yale CAS authentication' do
      visit root_path
      expect(page).to have_link('Sign in', href: '/users/auth/cas')
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
      logout(:user)
      login_as(user, scope: :user)

      expect(page).to have_content 'bookmark'
    end
  end
end
