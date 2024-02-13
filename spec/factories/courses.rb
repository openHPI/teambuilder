FactoryBot.define do
  factory :course do
    id { SecureRandom.uuid }
    sequence(:name) { |n| "Course #{n}" }
    auth_key { 'abc' }
    auth_secret { 'def' }
    url { 'www' }
    workflow_state { 'published' }
    platform_id { 'dummy' }

    trait :with_teams do
      after(:create) do |course|
        create(:team, course: course, name: 'Team 1')
        create(:team, :with_members, course: course, name: 'Team 2')
      end
    end
  end
end
