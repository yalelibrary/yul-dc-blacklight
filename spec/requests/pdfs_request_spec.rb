# frozen_string_literal: true

require 'rails_helper'

# WebMock.allow_net_connect!
RSpec.describe 'PdfController', type: :request do
  describe 'PDFs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/00/20/34/60/2034600.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
    end

    around do |example|
      original_sample_bucket = ENV['S3_SOURCE_BUCKET_NAME']
      ENV['S3_SOURCE_BUCKET_NAME'] = 'yul-test-samples'
      example.run
      ENV['S3_SOURCE_BUCKET_NAME'] = original_sample_bucket
    end

    describe 'GET /show' do
      it 'returns a pdf document of the oid' do
        get '/pdfs/2034600.pdf'
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/pdf'
        expect(response.body).to include 'PDF-1.4'
      end
    end
  end

  describe 'Not found Pdfs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/id/no/t_/re/al/_o/id/not_real_oid.pdf')
        .to_return(status: 404, body: 'not found')
    end

    around do |example|
      original_sample_bucket = ENV['S3_SOURCE_BUCKET_NAME']
      ENV['S3_SOURCE_BUCKET_NAME'] = 'yul-test-samples'
      example.run
      ENV['S3_SOURCE_BUCKET_NAME'] = original_sample_bucket
    end

    describe 'GET /show' do
      it 'redircts to HTML page' do
        get '/pdfs/not_real_oid.pdf'
        expect(response).to redirect_to '/pdfs/not_found.html'
      end
    end
  end
end
