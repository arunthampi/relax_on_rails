FactoryGirl.define do
  factory :identity do
    association :user, factory: :user
    sequence(:provider) { |n| "provider-#{n}" }
    sequence(:uid)      { |n| "#{n}" }
    sequence(:token)    { |n| "someToken#{n}" }
    sequence(:team_uid) { |n| "team-uid-#{n}" }
  end
end
