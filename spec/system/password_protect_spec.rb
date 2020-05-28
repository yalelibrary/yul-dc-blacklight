require 'rails_helper'

RSpec.describe 'Password protect non-production instances', type: :system do
  context 'visiting an instance without password protection' do
    before do
      ENV['HTTP_PASSWORD_PROTECT'] = 'false'
    end
    it 'does not prompt the user for a password' do
      visit('/')
      expect(page).to have_selector(".blacklight-catalog")
    end
  end
  context 'visiting an instance with http password protection' do
    before do
      ENV['HTTP_PASSWORD_PROTECT'] = 'true'
    end
    after do
      ENV['HTTP_PASSWORD_PROTECT'] = 'false'
    end
    it 'prompts the user for a password' do
      visit('/')
      expect(page).to have_content("HTTP Basic: Access denied")
    end
  end
end
