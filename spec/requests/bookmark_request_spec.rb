# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Open with Permission", type: :request, clean: true do
  let(:user) { FactoryBot.create(:user)}

  around do |example|
    original_management_url = ENV['MANAGEMENT_HOST']
    ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
    example.run
    ENV['MANAGEMENT_HOST'] = original_management_url
  end

  context 'as a signd in user' do
    before do
      login_as user
    end
    it 'can access the Saved Items page' do
      get "/bookmarks"
      expect(response).to have_http_status(:success)
    end
  end

  context 'as a logged out user' do
    it 'cannot access the Saved Items page' do
      get "/bookmarks"
      expect(response).to have_http_status(:redirect)
    end
  end
end
