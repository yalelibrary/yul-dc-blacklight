# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email }
    password {FFaker::Lorem.characters(8)}
  end
end