# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User Authentication', type: :system, js: false, clean: true do
  let(:user) { FactoryBot.create(:user) }

  context 'an unauthenticated user' do
    it 'gets the omniauth redirect endpoint for Yale CAS authentication' do
      visit root_path
      expect(page).to have_link('Sign in', href: '/users/auth/cas')
    end
  end
end
