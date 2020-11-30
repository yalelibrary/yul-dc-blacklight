# frozen_string_literal: true

require 'rails_helper'

# WebMock.allow_net_connect!
RSpec.describe 'PdfController', type: :request do
  let(:public_work) do
    {
      "id": "2034600",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Public"
    }
  end
  let(:pubic_work_with_no_pdf) do
    {
      "id": "202",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Public"
    }
  end
  let(:yale_work) do
    {
      "id": "1618909",
      "title_tesim": ["[Map of China]. [yale-only copy]"],
      "visibility_ssi": "Yale Community Only"
    }
  end
  let(:no_visibility_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"]
    }
  end
  describe 'PDFs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/00/20/34/60/2034600.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/09/16/18/90/1618909.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
      solr = Blacklight.default_index.connection
      solr.add([public_work, yale_work, no_visibility_work, pubic_work_with_no_pdf])
      solr.commit
      allow(User).to receive(:on_campus?).and_return(false)
    end

    around do |example|
      original_sample_bucket = ENV['S3_SOURCE_BUCKET_NAME']
      ENV['S3_SOURCE_BUCKET_NAME'] = 'yul-test-samples'
      example.run
      ENV['S3_SOURCE_BUCKET_NAME'] = original_sample_bucket
    end

    describe 'GET /show' do
      it 'returns a pdf document of the oid with public access' do
        get '/pdfs/2034600.pdf'
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/pdf'
        expect(response.body).to include 'PDF-1.4'
      end
      it 'returns not found for oid with no visibility' do
        get '/pdfs/1234567.pdf'
        expect(response).to have_http_status(:not_found)
      end
      it 'returns not found for oid with Yale Only' do
        get '/pdfs/1618909.pdf'
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'GET /show while on campus' do
      before do
        allow(User).to receive(:on_campus?).and_return(true)
      end
      it 'returns pdf for oid with Yale Only' do
        get '/pdfs/1618909.pdf'
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq 'application/pdf'
        expect(response.body).to include 'PDF-1.4'
      end
    end
  end

  describe 'Not found Pdfs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/02/20/202.pdf')
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
        get '/pdfs/202.pdf'
        expect(response).to redirect_to '/pdfs/not_found.html'
      end
    end
  end
end
