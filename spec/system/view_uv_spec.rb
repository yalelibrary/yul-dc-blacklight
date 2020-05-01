# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe 'viewing uv', type: :system do
  it 'has expected text' do
    visit "/uv/uv.html"
    expect(page.html).to match(/uv/)
  end
end
