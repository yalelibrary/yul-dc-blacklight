# frozen_string_literal: true

FactoryBot.define do
  # User objects are created from data passed from CAS.
  # The only field we get is uid. All user objects are given the
  # provider "cas"
  factory :user do
    uid { FFaker::Internet.user_name }
    sub { "123" }
    provider { "openid" }
    trait :ai_authorized do
      ai_user { true }
    end
    factory :guest_user do
      uid { "guest_" + SecureRandom.uuid }
      sub { FFaker::Number.number(digits: 10).to_s }
    end
  end
end
