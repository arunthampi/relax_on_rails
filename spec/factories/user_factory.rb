FactoryGirl.define do
  factory :user do
    sequence(:email)          { |n| "user-#{n}@asknestor.me" }
    password                  "password"
  end
end

