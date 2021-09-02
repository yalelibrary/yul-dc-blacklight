# frozen_string_literal: true
require 'spec_helper'

describe 'Compression', type: :request do
  it 'works on a browser that supports gzip' do
    get root_path, headers: { HTTP_ACCEPT_ENCODING: 'gzip' }
    expect(response.headers['Content-Encoding']).to be
  end

  it 'does not work on a browser that does not support gzip' do
    get root_path
    expect(response.headers['Content-Encoding']).not_to be
  end
end
