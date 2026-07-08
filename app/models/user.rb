# frozen_string_literal: true

require 'resolv'

class User < ApplicationRecord
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  devise :timeoutable, :omniauthable, omniauth_providers: [:openid_connect]
  validates :sub, presence: true

  def self.on_campus?(ip_address)
    return false unless Resolv::IPv4::Regex.match?(ip_address)
    on_campus_ip_ranges.any? do |ir|
      IPAddr.new(ir).include?(ip_address)
    end
  end

  def self.on_campus_ip_ranges
    (ENV['YALE_NETWORK_IPS'] || "10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,127.0.0.1").split(',')
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    uid
  end

  # Devise 5.0.4's serialize_from_session(key, salt) has a fixed 2-arg arity, but
  # Warden calls it as serialize_from_session(*stored_key). Cookies written by older
  # Devise/Rails versions can store a 1- or 3-element key, which raises ArgumentError
  # on read and 500s the request. Accept any arity, extract the id defensively, and
  # treat anything unreadable as "no session" so a stale cookie logs the user out
  # instead of crashing. See: https://github.com/heartcombo/devise/issues/5752
  def self.serialize_from_session(*args)
    key = args.first
    record_id =
      case key
      when Hash  then key["id"] || key[:id]
      when Array then Array(key).flatten.first
      else key
      end
    return nil if record_id.blank?

    find_by(id: record_id)
  rescue StandardError => e
    Rails.logger.warn("serialize_from_session: discarding unreadable session (#{e.class}: #{e.message})")
    nil
  end
end
