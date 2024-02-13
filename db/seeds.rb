# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

course_id = '5abd9018-1887-47b0-85ca-93b442e9e5dd'

# Delete the old course if it exists
Course.where(id: course_id).destroy_all

course = Course.create(
  id: course_id,
  name: 'Seed Course',
  auth_key: 'abc',
  auth_secret: 'def',
  url: 'www',
  platform_id: 'dummy',
  workflow_state: 'published'
)

course.features = [
  TeamBuilder::CourseFeatures::LanguageTeams.new('similar'),
  TeamBuilder::CourseFeatures::Timezone.new,
  TeamBuilder::CourseFeatures::LocalTeams.new(100),
  TeamBuilder::CourseFeatures::AreaOfExpertise.new(),
  TeamBuilder::CourseFeatures::PreferredTasks.new(%w(task1 task2 task3)),
  TeamBuilder::CourseFeatures::Commitment.new(),
  TeamBuilder::CourseFeatures::Age.new(),
  TeamBuilder::CourseFeatures::Gender.new()
]

require 'csv'
csv_text = File.read Rails.root.join('db', 'seed_data.csv')
csv = CSV.parse csv_text, headers: true

csv.each_with_index { |row, index|
  enrollment_data = course.features.map{ |feature|
    feature.submission(row.to_hash.merge({'preferred_task' => rand(0..2),
                                          'age' => ['1-19',
                                                    '20-29',
                                                    '30-39',
                                                    '40-49',
                                                    '50-59',
                                                    '60-69',
                                                    '70 and older'
                                          ].sample ,
                                         'gender' => ['male', 'female'].sample}))
  }.compact.reduce({}, :merge)

  course.enrollments << Enrollment.new(
    user_id: row['uuid'],
    name: Forgery::Name.full_name,
    email: Forgery::Email.address,
    data: enrollment_data,
    created_at: Time.new - index.days
  )
}
