# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Project Identifier Search", type: :system, clean: true, js: false do
  let(:user) { FactoryBot.create(:user) }

  let(:yale_work) do
    {
      id: "1234567",
      title_tesim: ["Fake Work"],
      project_identifier_tesi: "def",
      visibility_ssi: 'Public'
    }
  end
  let(:child_work1) do
    {
      id: "3456789",
      title_tesim: ["Faker Work"],
      project_identifier_tesi: "abc",
      visibility_ssi: 'Public'
    }
  end
  let(:child_work2) do
    {
      id: "3457873",
      title_tesim: ["Fakest Work"],
      project_identifier_tesi: "abc",
      visibility_ssi: 'Public'
    }
  end

  before do
    solr = Blacklight.default_index.connection
    solr.add([yale_work, child_work1, child_work2])
    solr.commit
    allow(User).to receive(:on_campus?).and_return(true)
  end

  describe "Project Identifier search" do
    it 'matches document when query does match' do
      visit "/catalog?f[project_identifier_tesi][]=abc&q=&search_field=all_fields"
      expect(page).to have_content 'Faker Work'
      expect(page).to have_content 'Fakest Work'
      expect(page).not_to have_content 'Fake Work'
    end
  end
end
