# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ManagementClient do
  around do |example|
    original_host = ENV['MANAGEMENT_HOST']
    original_token = ENV['OWP_AUTH_TOKEN']
    ENV['MANAGEMENT_HOST'] = 'https://www.example.com/management'
    ENV['OWP_AUTH_TOKEN'] = 'valid'
    example.run
    ENV['MANAGEMENT_HOST'] = original_host
    ENV['OWP_AUTH_TOKEN'] = original_token
  end

  describe 'configuration enforcement' do
    it 'raises NotConfigured when MANAGEMENT_HOST is unset' do
      ENV.delete('MANAGEMENT_HOST')
      expect { described_class.permissions_for_user('abc') }.to raise_error(ManagementClient::NotConfigured, /MANAGEMENT_HOST/)
    end

    it 'raises NotConfigured when MANAGEMENT_HOST is http://' do
      ENV['MANAGEMENT_HOST'] = 'http://www.example.com/management'
      expect { described_class.permissions_for_user('abc') }
        .to raise_error(ManagementClient::NotConfigured, /must be https/)
    end

    it 'raises NotConfigured when OWP_AUTH_TOKEN is unset for an authenticated call' do
      ENV.delete('OWP_AUTH_TOKEN')
      expect { described_class.permissions_for_user('abc') }
        .to raise_error(ManagementClient::NotConfigured, /OWP_AUTH_TOKEN/)
    end

    it 'does NOT require OWP_AUTH_TOKEN for stage_child_download (preserves existing no-auth behavior)' do
      ENV.delete('OWP_AUTH_TOKEN')
      stub_request(:get, 'https://www.example.com/management/api/download/stage/child/3333333')
        .to_return(status: 200, body: '')
      expect { described_class.stage_child_download(3_333_333) }.not_to raise_error
    end
  end

  describe 'path encoding (defense against / and .. traversal)' do
    it 'percent-encodes a netid containing /' do
      stub = stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/foo%2Fbar')
             .with(headers: { 'Authorization' => 'Bearer valid' })
             .to_return(status: 200, body: '{"is_admin_or_approver?":"false"}')
      described_class.admin_credentials(1, 'foo/bar')
      expect(stub).to have_been_requested
    end

    it 'percent-encodes a netid containing ..' do
      stub = stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/..%2Fadmin')
             .to_return(status: 200, body: '{}')
      described_class.admin_credentials(1, '../admin')
      expect(stub).to have_been_requested
    end

    it 'percent-encodes a sub containing spaces' do
      stub = stub_request(:get, 'https://www.example.com/management/api/permission_sets/abc%20def')
             .to_return(status: 200, body: '{}')
      described_class.permissions_for_user('abc def')
      expect(stub).to have_been_requested
    end
  end

  describe 'GET helpers — status-aware parsing (fail-closed)' do
    it 'returns the parsed body on 200' do
      stub_request(:get, 'https://www.example.com/management/api/permission_sets/abc')
        .to_return(status: 200, body: '{"permissions":[]}')
      expect(described_class.permissions_for_user('abc')).to eq('permissions' => [])
    end

    it 'returns nil on 4xx (so admin_of_owp? short-circuits to fail-closed)' do
      stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/net')
        .to_return(status: 401, body: 'unauthorized')
      expect(described_class.admin_credentials(1, 'net')).to be_nil
    end

    it 'returns nil on 5xx' do
      stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/net')
        .to_return(status: 500, body: 'server error')
      expect(described_class.admin_credentials(1, 'net')).to be_nil
    end

    it 'returns nil on a 200 with malformed JSON (does not poison @credentials)' do
      stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/net')
        .to_return(status: 200, body: 'not json')
      expect(described_class.admin_credentials(1, 'net')).to be_nil
    end

    it 'returns nil on transport failure (e.g. SSL error)' do
      stub_request(:get, 'https://www.example.com/management/api/permission_sets/1/net')
        .to_raise(OpenSSL::SSL::SSLError.new('cert verify failed'))
      expect(described_class.admin_credentials(1, 'net')).to be_nil
    end
  end

  describe 'POST helpers — return Result with actual API status/body' do
    it 'returns Result with status 201 and the API body on success' do
      stub_request(:post, 'https://www.example.com/management/api/permission_requests')
        .with(headers: { 'Authorization' => 'Bearer valid' })
        .to_return(status: 201, body: 'Created')
      result = described_class.create_permission_request(form: { 'oid' => '1' })
      expect(result.status).to eq(201)
      expect(result.body).to eq('Created')
    end

    it 'returns Result with status 400 and the API body on rejection (proves bug fix)' do
      stub_request(:post, 'https://www.example.com/management/api/permission_requests')
        .to_return(status: 400, body: 'Object is private')
      result = described_class.create_permission_request(form: { 'oid' => '1' })
      expect(result.status).to eq(400)
      expect(result.body).to eq('Object is private')
    end

    it 'returns Result with status 0 on transport failure' do
      stub_request(:post, 'https://www.example.com/management/agreement_term')
        .to_raise(Errno::ECONNREFUSED)
      result = described_class.submit_agreement_term(form: {})
      expect(result.status).to eq(0)
      expect(result.body).to be_nil
    end
  end

  describe 'authorization header' do
    it 'sends Bearer OWP_AUTH_TOKEN on authenticated calls' do
      stub = stub_request(:get, 'https://www.example.com/management/api/permission_sets/abc')
             .with(headers: { 'Authorization' => 'Bearer valid' })
             .to_return(status: 200, body: '{}')
      described_class.permissions_for_user('abc')
      expect(stub).to have_been_requested
    end

    it 'does not send any Authorization header on stage_child_download' do
      stub = stub_request(:get, 'https://www.example.com/management/api/download/stage/child/77')
             .with { |req| !req.headers.key?('Authorization') }
             .to_return(status: 200, body: '')
      described_class.stage_child_download(77)
      expect(stub).to have_been_requested
    end
  end
end
