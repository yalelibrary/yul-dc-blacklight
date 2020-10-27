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
      id: '111',
      subjectTopic_tesim: ['subject1', 'subject2']
    }
  end

  describe 'add line breaks to subjects' do
    it 'adds a line break when multiple subjectTopic_tesim' do
      visit '/catalog/111'
      expect(page.html).to match(llama[:subjectTopic_tesim].join('<br/>'))
    end
  end
end
