# frozen_string_literal: true
require 'rails_helper'

# The CSP initializer runs in the test environment in report-only mode so the
# header ships for inspection without affecting other request behavior. See
# config/initializers/content_security_policy.rb.
RSpec.describe 'Content-Security-Policy header', type: :request do
  def csp_header
    response.headers['Content-Security-Policy'] ||
      response.headers['Content-Security-Policy-Report-Only']
  end

  it 'emits a per-request nonce in script-src-elem' do
    get root_path
    expect(csp_header).to be_present
    expect(csp_header).to match(/script-src-elem [^;]*'nonce-[A-Za-z0-9+\/=]+'/)
  end

  it "does not allow 'unsafe-inline' in script-src-elem" do
    get root_path
    expect(csp_header).not_to match(/script-src-elem [^;]*'unsafe-inline'/)
  end

  it "does not allow 'unsafe-inline' in script-src-attr" do
    get root_path
    expect(csp_header).not_to match(/script-src-attr [^;]*'unsafe-inline'/)
  end

  it 'returns a fresh nonce on each request (not session-derived)' do
    get root_path
    nonce1 = csp_header[/'nonce-([^']+)'/, 1]
    get root_path
    nonce2 = csp_header[/'nonce-([^']+)'/, 1]
    expect(nonce1).to be_present
    expect(nonce2).to be_present
    expect(nonce1).not_to eq(nonce2)
  end
end
