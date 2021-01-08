# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Metadata line breaks', type: :system, clean: true do
  let(:user) { FactoryBot.create(:user) }

  before do
    solr = Blacklight.default_index.connection
    solr.add([llama])
    solr.commit
  end

  let(:llama) do
    {
      id: '11111',
      visibility_ssi: "Public",
      subjectName_ssim: ['Langston Hughes', 'James Weldon Johnson'],
      subjectGeographic_tesim: ['New Haven', 'New York City', 'Boston']
    }
  end

  describe 'add line breaks to subjects' do
    it 'adds a line break when multiple subjects' do
      visit "/catalog/#{llama[:id]}"
      expect(page.html).to match(llama[:subjectName_ssim].join('<br/>'))
      expect(page.html).to match(llama[:subjectGeographic_tesim].join('<br/>'))
    end
  end
end
