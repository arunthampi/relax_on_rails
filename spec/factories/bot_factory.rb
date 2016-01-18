FactoryGirl.define do
  factory :bot do
    association :team, factory: :team
    association :creator, factory: :user

    sequence(:token) { |n| "token-#{n}" }
  end
end
