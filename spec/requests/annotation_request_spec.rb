# frozen_string_literal: true

require 'rails_helper'

# WebMock.allow_net_connect!
RSpec.describe 'AnnotationsController', type: :request do
  let(:public_work) do
    {
      "id": "2034600",
      "title_tesim": ["[Map of China]. [public copy]"],
      "visibility_ssi": "Public"
    }
  end
  let(:child_work) do
    {
      "id": "998833",
      "parent_ssi": "2034600",
      "child_fulltext_tsim": ["This is the full text public"]
    }
  end
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only"
    }
  end
  let(:child_work_yale_only) do
    {
      "id": "998834",
      "parent_ssi": "1618909",
      "child_fulltext_tsim": ["This is the full text Yale only"]
    }
  end

  describe 'Full Text' do
    before do
      solr = Blacklight.default_index.connection
      solr.add([public_work, yale_work, child_work, child_work_yale_only])
      solr.commit
      allow(User).to receive(:on_campus?).and_return(false)
    end

    describe 'GET /annotation/ .. /fulltext' do
      it 'returns a full text annotation' do
        get '/annotation/oid/2034600/canvas/998833/fulltext'
        expect(response).to have_http_status(:success)
        expect(response.body).to include("This is the full text public")
      end
      it 'returns 401 for a full text annotation on Yale Only parent' do
        get '/annotation/oid/1618909/canvas/998834/fulltext'
        expect(response).to have_http_status(:unauthorized)
      end
      it 'returns 401 for a full text annotation because of mismatch parent' do
        get '/annotation/oid/2034600/canvas/998834/fulltext'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe 'GET /annotation/ .. /fulltext while on campus' do
      before do
        allow(User).to receive(:on_campus?).and_return(true)
      end
      it 'returns a full text annotation' do
        get '/annotation/oid/2034600/canvas/998833/fulltext'
        expect(response).to have_http_status(:success)
        expect(response.body).to include("This is the full text public")
      end
      it 'returns a full text annotation on yale only' do
        get '/annotation/oid/1618909/canvas/998834/fulltext'
        expect(response).to have_http_status(:success)
        expect(response.body).to include("This is the full text Yale only")
      end
      it 'returns 401 for a full text annotation because of mismatch parent' do
        get '/annotation/oid/2034600/canvas/998834/fulltext'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
