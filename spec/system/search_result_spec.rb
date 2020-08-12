require 'rails_helper'

RSpec.describe 'search result', type: :system do
  before do
    visit '/?search_field=all_fields&q='
  end

  it 'has expected css' do
    expect(page).to have_css '.document-metadata'
  end
end