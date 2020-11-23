# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  around do |example|
    original_value = ENV["YALE_NETWORK_IPS"]
    ENV["YALE_NETWORK_IPS"] = "188.99.55.0/24,99.88.0.0/16,22.33.44.55"
    example.run
    ENV["YALE_NETWORK_IPS"] = original_value
  end
  describe "User class method on_campus?" do
    it "returns true if matches an 24 bit IP range" do
      expect(described_class.on_campus?("188.99.55.44")).to be_truthy
    end
    it "returns false if not in 24 bit IP range" do
      expect(described_class.on_campus?("188.19.56.44")).to be_falsey
    end
    it "returns true if matches a 16 bit IP range" do
      expect(described_class.on_campus?("99.88.244.55")).to be_truthy
    end
    it "returns false if not in 16 bit IP range" do
      expect(described_class.on_campus?("99.89.244.55")).to be_falsey
    end
    it "returns true if exact match of IP" do
      expect(described_class.on_campus?("22.33.44.55")).to be_truthy
    end
  end

  describe "when YALE_NETWORK_IPS environment variable is not set, User.on_campus?" do
    around do |example|
      original_value = ENV["YALE_NETWORK_IPS"]
      ENV["YALE_NETWORK_IPS"] = nil
      example.run
      ENV["YALE_NETWORK_IPS"] = original_value
    end
    it "returns true for private ips" do
      expect(described_class.on_campus?("192.168.1.253")).to be_truthy
      expect(described_class.on_campus?("172.16.0.20")).to be_truthy
      expect(described_class.on_campus?("10.0.1.5")).to be_truthy
    end
    it "returns true for localhost" do
      expect(described_class.on_campus?("127.0.0.1")).to be_truthy
    end
    it "returns false non private ips" do
      expect(described_class.on_campus?("188.19.56.44")).to be_falsey
      expect(described_class.on_campus?("18.193.56.44")).to be_falsey
    end
  end

  describe "when user is not a guest, User.can_view_yale_only?" do
    let(:user) { FactoryBot.create(:user, uid: "mk2525", guest: false) }
    it "returns true, regardless of IP" do
      expect(user.can_view_yale_only?("xxxxx")).to be_truthy
    end
  end

  describe "when user is a guest, User.can_view_yale_only?" do
    let(:user) { FactoryBot.create(:user, uid: "mk2525", guest: true) }
    it "returns true, if valid IP" do
      expect(user.can_view_yale_only?("99.88.244.55")).to be_truthy
    end
    it "returns false, if not valid IP" do
      expect(user.can_view_yale_only?("99.188.244.55")).to be_falsey
    end
  end
end
