# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Yul::System::ModalComponent, type: :system do
  it 'has expected content' do
    expect(described_class.with_content_areas).to eq []
  end
end
