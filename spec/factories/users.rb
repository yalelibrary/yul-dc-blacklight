# frozen_string_literal: true

FactoryBot.define do
  # User objects are created from data passed from CAS.
  # The only field we get is uid. All user objects are given the
  # provider "cas"
  factory :user do
    uid { FFaker::Internet.user_name }
    provider { "cas" }
  end
end
