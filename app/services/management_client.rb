# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'
require 'erb'
require 'json'

class ManagementClient
  class Error          < StandardError; end
  class NotConfigured  < Error; end

  Result = Struct.new(:status, :body, :parsed, keyword_init: true)

  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 15

  def self.permissions_for_user(sub)
    execute(method: :get, path: "/api/permission_sets/#{encode(sub)}").parsed
  end

  def self.permission_set_terms(parent_oid)
    execute(method: :get, path: "/api/permission_sets/#{encode(parent_oid)}/terms").parsed
  end

  def self.admin_credentials(document_id, netid)
    execute(method: :get, path: "/api/permission_sets/#{encode(document_id)}/#{encode(netid)}").parsed
  end

  def self.stage_child_download(child_oid)
    execute(method: :get,
            path: "/api/download/stage/child/#{encode(child_oid)}",
            auth: false)
    nil
  end

  def self.create_permission_request(form:)
    execute(method: :post, path: '/api/permission_requests', form: form)
  end

  def self.submit_agreement_term(form:)
    execute(method: :post, path: '/agreement_term', form: form)
  end

  def self.execute(method:, path:, form: nil, auth: true)
    uri = build_uri(path)
    request = build_request(method, uri, form, auth)
    Net::HTTP.start(uri.host, uri.port,
                    use_ssl: uri.scheme == 'https',
                    verify_mode: OpenSSL::SSL::VERIFY_PEER,
                    open_timeout: OPEN_TIMEOUT,
                    read_timeout: READ_TIMEOUT) do |http|
      response = http.request(request)
      Result.new(status: response.code.to_i,
                 body: response.body,
                 parsed: safe_parse(response))
    end
  rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ECONNREFUSED,
         OpenSSL::SSL::SSLError, SocketError => e
    Rails.logger.warn("ManagementClient #{method.upcase} #{path} failed: #{e.class} #{e.message}")
    Result.new(status: 0, body: nil, parsed: nil)
  end
  private_class_method :execute

  def self.build_uri(path)
    base = ENV.fetch('MANAGEMENT_HOST') { raise NotConfigured, 'MANAGEMENT_HOST is not set' }
    raise NotConfigured, "MANAGEMENT_HOST must be https:// (got #{base.inspect})" unless base.start_with?('https://')
    URI.parse("#{base.chomp('/')}#{path}")
  end
  private_class_method :build_uri

  def self.build_request(method, uri, form, auth)
    request_class = method == :post ? Net::HTTP::Post : Net::HTTP::Get
    request = request_class.new(uri.request_uri)
    request.set_form_data(form) if form && method == :post
    if auth
      token = ENV.fetch('OWP_AUTH_TOKEN') { raise NotConfigured, 'OWP_AUTH_TOKEN is not set' }
      request['Authorization'] = "Bearer #{token}"
    end
    request
  end
  private_class_method :build_request

  def self.safe_parse(response)
    return nil unless (200..299).cover?(response.code.to_i)
    return nil if response.body.nil? || response.body.empty?
    JSON.parse(response.body)
  rescue JSON::ParserError => e
    Rails.logger.warn("ManagementClient JSON parse error: #{e.message}")
    nil
  end
  private_class_method :safe_parse

  def self.encode(segment)
    ERB::Util.url_encode(segment.to_s)
  end
  private_class_method :encode
end
