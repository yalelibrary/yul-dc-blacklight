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
end
