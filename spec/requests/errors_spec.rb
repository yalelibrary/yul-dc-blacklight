# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Errors', type: :request do
  describe ':not_found' do
    context 'for a 404 page' do
      before(:all) { get '/404' }

      it 'have an http status of 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'redirect to the custom not_found error page' do
        expect(response.body).to include("The page you were looking for doesn't exist.")
      end
    end
  end

  context 'for invalid paths' do
    before(:all) { get '/alpha' }

    it 'have an http status of 404' do
      expect(response).to have_http_status(:not_found)
    end

    it 'redirect to the custom not_found error page' do
      expect(response.body).to include("The page you were looking for doesn't exist.")
    end
  end

  context 'for invalid paths with non-html formats' do
    it 'returns a json 404 for .json' do
      get '/test.json'
      expect(response).to have_http_status(:not_found)
      expect(response.media_type).to eq('application/json')
      expect(JSON.parse(response.body)).to eq('error' => 'Not found')
    end

    ['/test.webm', '/test.text', '/test.txt', '/test.xml', '/test.php', '/test.zzz'].each do |path|
      it "returns a plain 404 for #{path}" do
        get path
        expect(response).to have_http_status(:not_found)
        expect(response.media_type).to eq('text/plain')
        expect(response.body).to eq('Not found')
      end
    end

    it 'returns a plain 404 for an unusual Accept header' do
      get '/test', headers: { 'Accept' => 'video/webm' }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq('Not found')
    end

    it 'returns the html 404 page for a wildcard Accept header' do
      get '/test', headers: { 'Accept' => '*/*' }
      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("The page you were looking for doesn't exist.")
    end
  end

  it 'has content for PDF not found page' do
    get '/pdfs/not_found.html'
    expect(response.body).to include("We're sorry, but the item you've requested does not appear to exist")
    expect(response).to have_http_status(:not_found)
  end
end
