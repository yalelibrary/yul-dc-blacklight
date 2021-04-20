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
end
