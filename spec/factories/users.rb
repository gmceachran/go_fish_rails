FactoryBot.define do
  factory :user do
    email_address { generate :email }
    password { "password" }
    password_confirmation { password }
  end

  sequence :email do |n|
    "user#{n}@example.com"
  end
end
