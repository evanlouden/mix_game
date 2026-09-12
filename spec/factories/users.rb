# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { sequence(:email) { |n| "test#{n}@example.com" } }
    password { "password" }
  end
end
