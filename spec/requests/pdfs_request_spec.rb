# frozen_string_literal: true

require 'rails_helper'

# WebMock.allow_net_connect!
RSpec.describe 'PdfController', type: :request do
  let(:yale_user) { FactoryBot.create(:user, netid: 'netid', sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6e', uid: 'sun345') }
  let(:non_yale_user) { FactoryBot.create(:user, sub: '7bd425ee-1093-40cd-ba0c-5a2355e37d6f', uid: 'moon678') }
  let(:public_work) do
    {
      "id": "2034600",
      "title_tesim": ["[Map of China]. [public copy]"],
      "visibility_ssi": "Public"
    }
  end
  let(:pubic_work_with_no_pdf) do
    {
      "id": "202",
      "title_tesim": ["[Map of China]. [public copy]"],
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
  let(:owp_work) do
    {
      "id": "1818909",
      "title_tesim": ["[Map of Australia]. [owp-only copy]"],
      "visibility_ssi": "Open with Permission"
    }
  end
  let(:no_visibility_work) do
    {
      "id": "1234567",
      "title_tesim": ["Fake Work"]
    }
  end
  let(:redirected_work) { WORK_REDIRECTED }

  describe 'PDFs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/00/20/34/60/2034600.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/09/16/18/90/1618909.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/09/18/18/90/1818909.pdf')
        .to_return(status: 200, body: File.open(File.join('spec', 'fixtures', '2034600.pdf')).read)
      stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6e')
        .to_return(status: 200, body: '{
          "timestamp":"2023-11-02",
          "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6e"},
          "permission_set_terms_agreed":[],
          "permissions":[]}')
      stub_request(:get, "http://www.example.com/management/api/permission_sets/1818909/netid")
        .to_return(status: 200, body: '{ "is_admin_or_approver?": "false" }')
      stub_request(:get, 'http://www.example.com/management/api/permission_sets/7bd425ee-1093-40cd-ba0c-5a2355e37d6f')
        .to_return(status: 200, body: '{
          "timestamp":"2023-11-02",
          "user":{"sub":"7bd425ee-1093-40cd-ba0c-5a2355e37d6f"},
          "permission_set_terms_agreed":[],
          "permissions":[]}')

      solr = Blacklight.default_index.connection
      solr.add([public_work, yale_work, owp_work, no_visibility_work, pubic_work_with_no_pdf, redirected_work])
      solr.commit
      allow(S3Service).to receive(:etag).and_return("TEST")
      allow(User).to receive(:on_campus?).and_return(false)
    end

    around do |example|
      original_management_url = ENV['MANAGEMENT_HOST']
      original_token = ENV['OWP_AUTH_TOKEN']
      original_sample_bucket = ENV['S3_SOURCE_BUCKET_NAME']
      ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
      ENV['OWP_AUTH_TOKEN'] = 'valid'
      ENV['S3_SOURCE_BUCKET_NAME'] = 'yul-test-samples'
      example.run
      ENV['MANAGEMENT_HOST'] = original_management_url
      ENV['OWP_AUTH_TOKEN'] = original_token
      ENV['S3_SOURCE_BUCKET_NAME'] = original_sample_bucket
    end

    describe 'GET /show' do
      context 'with unauthenticated user' do
        context 'while not on campus' do
          it 'returns a pdf document of the oid with public access' do
            get '/pdfs/2034600.pdf'
            expect(response).to have_http_status(:success)
            expect(response.content_type).to eq 'application/pdf'
            expect(response.body).to include 'PDF-1.4'
            expect(response.headers['X-Robots-Tag']).to be('noindex')
          end
          it 'returns unauthorized for oid with no visibility' do
            get '/pdfs/1234567.pdf'
            expect(response).to have_http_status(:unauthorized)
          end
          it 'returns unauthorized for oid with Yale Only' do
            get '/pdfs/1618909.pdf'
            expect(response).to have_http_status(:unauthorized)
          end
          it 'returns unauthorized for oid with Open with Permission' do
            get '/pdfs/1818909.pdf'
            expect(response).to have_http_status(:unauthorized)
          end
          it 'returns not found for oid with Redirect' do
            get '/pdfs/16685691.pdf'
            expect(response).to have_http_status(:not_found)
          end
        end
        context 'while on campus' do
          before do
            allow(User).to receive(:on_campus?).and_return(true)
          end
          it 'returns a pdf document of the oid with public access' do
            get '/pdfs/2034600.pdf'
            expect(response).to have_http_status(:success)
            expect(response.content_type).to eq 'application/pdf'
            expect(response.body).to include 'PDF-1.4'
            expect(response.headers['X-Robots-Tag']).to be('noindex')
          end
          it 'returns unauthorized for oid with no visibility' do
            get '/pdfs/1234567.pdf'
            expect(response).to have_http_status(:unauthorized)
          end
          it 'returns pdf for oid with Yale Only' do
            get '/pdfs/1618909.pdf'
            expect(response).to have_http_status(:success)
            expect(response.content_type).to eq 'application/pdf'
            expect(response.body).to include 'PDF-1.4'
          end
          it 'returns unauthorized for oid with Open with Permission' do
            get '/pdfs/1818909.pdf'
            expect(response).to have_http_status(:unauthorized)
          end
          it 'returns not found for oid with Redirect' do
            get '/pdfs/16685691.pdf'
            expect(response).to have_http_status(:not_found)
          end
        end
      end

      context 'with authenticated yale user' do
        before do
          sign_in yale_user
        end
        it 'returns a pdf document of the oid with public access' do
          get '/pdfs/2034600.pdf'
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq 'application/pdf'
          expect(response.body).to include 'PDF-1.4'
          expect(response.headers['X-Robots-Tag']).to be('noindex')
        end
        it 'returns not found for oid with no visibility' do
          get '/pdfs/1234567.pdf'
          expect(response).to have_http_status(:unauthorized)
        end
        it 'returns pdf for oid with Yale Only' do
          get '/pdfs/1618909.pdf'
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq 'application/pdf'
          expect(response.body).to include 'PDF-1.4'
        end
        it 'returns unauthorized for oid with Open with Permission' do
          get '/pdfs/1818909.pdf'
          expect(response).to have_http_status(:unauthorized)
        end
        it 'returns not found for oid with Redirect' do
          get '/pdfs/16685691.pdf'
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'with authenticated non yale user' do
        before do
          sign_in non_yale_user
        end
        it 'returns a pdf document of the oid with public access' do
          get '/pdfs/2034600.pdf'
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq 'application/pdf'
          expect(response.body).to include 'PDF-1.4'
          expect(response.headers['X-Robots-Tag']).to be('noindex')
        end
        it 'returns not found for oid with no visibility' do
          get '/pdfs/1234567.pdf'
          expect(response).to have_http_status(:unauthorized)
        end
        it 'returns unauthorized for oid with Yale Only' do
          get '/pdfs/1618909.pdf'
          expect(response).to have_http_status(:unauthorized)
        end
        it 'returns unauthorized for oid with Open with Permission' do
          get '/pdfs/1818909.pdf'
          expect(response).to have_http_status(:unauthorized)
        end
        it 'returns not found for oid with Redirect' do
          get '/pdfs/16685691.pdf'
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  describe 'Not found Pdfs' do
    before do
      stub_request(:get, 'https://yul-test-samples.s3.amazonaws.com/pdfs/02/20/202.pdf')
        .to_return(status: 404, body: 'not found')
      stub_request(:head, 'https://yul-test-samples.s3.amazonaws.com/pdfs/02/20/202.pdf')
        .to_return(status: 404, body: 'not found')
      allow(S3Service).to receive(:etag).and_return("TEST")
    end

    around do |example|
      original_sample_bucket = ENV['S3_SOURCE_BUCKET_NAME']
      ENV['S3_SOURCE_BUCKET_NAME'] = 'yul-test-samples'
      example.run
      ENV['S3_SOURCE_BUCKET_NAME'] = original_sample_bucket
    end

    describe 'GET /show' do
      let(:logger_mock) { instance_double("Rails.logger").as_null_object }
      it 'redirects to HTML page' do
        allow(Rails.logger).to receive(:error) { :logger_mock }
        get '/pdfs/202.pdf'
        expect(response).to redirect_to '/pdfs/not_found.html'
        expect(Rails.logger).to have_received(:error)
          .with("Error reading PDF with id [202]: Aws::S3::Errors::NotFound")
      end
    end
  end
end
