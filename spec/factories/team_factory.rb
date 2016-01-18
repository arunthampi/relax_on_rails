FactoryGirl.define do
  factory :team do
    sequence(:uid)  { |n| "#{n}" }
    sequence(:name) { |n| "Team #{n}" }
    sequence(:url)  { |n| "https://example-#{n}.com" }
  end
end
