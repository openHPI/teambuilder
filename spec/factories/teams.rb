FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }
    course

    trait :with_members do
      after(:create) do |team|
        team.members = [create(:enrollment, :with_timezone, course: team.course),
                        create(:enrollment, :with_timezone, course: team.course)]
      end
    end
  end
end
