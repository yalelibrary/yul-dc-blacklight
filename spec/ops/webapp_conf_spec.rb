# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nginx webapp.conf hardening' do
  let(:config_path) { Rails.root.join('ops', 'webapp.conf') }
  let(:config) { File.read(config_path) }

  it 'rejects client-supplied X-Origin-URI headers at the server edge' do
    expect(config).to match(/if \(\$http_x_origin_uri != ""\)\s*\{\s*return 400;\s*\}/m)
  end

  it 'uses internal auth subrequests for iiif access checks' do
    expect(config).to include('auth_request     /auth;')
  end

  it 'restricts /auth to internal nginx traffic only' do
    expect(config).to match(/location = \/auth \{\s*internal;/m)
  end

  it 'sets X-Origin-URI from the current request URI for auth checks' do
    expect(config).to include('proxy_set_header X-Origin-URI $request_uri;')
  end
end
