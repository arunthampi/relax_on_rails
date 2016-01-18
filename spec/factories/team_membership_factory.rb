FactoryGirl.define do
  factory :team_membership do
    association :team, factory: :team
    association :user, factory: :user

    sequence(:user_uid) { |n| "user-uid-#{n}" }
  end
end

