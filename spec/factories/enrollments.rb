FactoryBot.define do
  factory :enrollment do
    name { 'asdf' }
    course

    trait :with_timezone do
      data { { timezone: '-18000' } }
    end
  end
end
