class CourseFactory
  def self.generate_course
    Course.create(
      id: 3,
      name: 'test course',
      auth_key: 'abc',
      auth_secret: 'def',
      url: 'www',
      platform_id: 'dummy',
      workflow_state: 'published'
    )
  end

  def self.add_enrollments_to(course)
    course.enrollments << new_enrollment(0, 'A', 100)
    course.enrollments << new_enrollment(1, 'B', 99)
    course.enrollments << new_enrollment(2, 'C', 97)
    course.enrollments << new_enrollment(3, 'D', 99)
    course.enrollments << new_enrollment(4, 'E', 95)
    course.enrollments << new_enrollment(5, 'F', 99)
    course.enrollments << new_enrollment(6, 'G', 100)
  end

  def self.add_enrollments_with_commitment_to(course)
    course.enrollments << new_enrollment(0, "A", 100, commitment: '5-6 Hours')
    course.enrollments << new_enrollment(1, "B", 100, commitment: '3-4 Hours')
    course.enrollments << new_enrollment(2, "C", 100, commitment: '1-2 Hours')
    course.enrollments << new_enrollment(3, "D", 100, commitment: '3-4 Hours')
    course.enrollments << new_enrollment(4, "E", 100, commitment: '5-6 Hours')
    course.enrollments << new_enrollment(5, "F", 100, commitment: '1-2 Hours')
  end

  def self.add_enrollments_with_age_to(course)
    course.enrollments << new_enrollment(0, "A", 100, age: '1-19')
    course.enrollments << new_enrollment(1, "B", 100, age: '20-29')
    course.enrollments << new_enrollment(2, "C", 100, age: '1-19')
    course.enrollments << new_enrollment(3, "D", 100, age: '20-29')
    course.enrollments << new_enrollment(4, "E", 100, age: '1-19')
    course.enrollments << new_enrollment(5, "F", 100, age: '20-29')
  end

  AGE = [
    '1-19',
    '20-29',
    '30-39',
    '40-49',
    '50-59',
    '60-69',
    '70 and older'
  ]
  COMMITMENT = ['1-2 Hours', '3-4 Hours', '5-6 Hours']
  EXPERTISE = [
    'Business and Management',
    'Computer Science and Engineering',
    'Life Science',
    'Creative Design',
    'Humanities',
    'Media',
    'Social Science',
    'Other'
  ]

  def self.add_a_lot_of_enrollements_to(course)
    500.times do |i|
      course.enrollments << new_enrollment(i, "A", 100, age: AGE[i%7], commitment: COMMITMENT[i%3], area_of_expertise: EXPERTISE[i%8])
    end
  end

  def self.add_enrollments_with_age_and_commitment_to(course)
    course.enrollments << new_enrollment(0, "A", 100, age: '1-19', commitment: '5-6 Hours')
    course.enrollments << new_enrollment(1, "B", 100, age: '20-29', commitment: '3-4 Hours')
    course.enrollments << new_enrollment(2, "C", 100, age: '1-19', commitment: '5-6 Hours')
    course.enrollments << new_enrollment(3, "D", 100, age: '20-29', commitment: '1-2 Hours')
    course.enrollments << new_enrollment(4, "E", 100, age: '1-19', commitment: '1-2 Hours')
    course.enrollments << new_enrollment(5, "F", 100, age: '20-29', commitment: '1-2 Hours')
  end

  def self.new_enrollment(index, name, score, **args)
    data = {commitment: args[:commitment], age: args[:age], area_of_expertise: args[:area_of_expertise], language: args[:language], preferred_task: args[:preferred_task], timezone: args[:timezone], gender: args[:gender]}
    Enrollment.new(
      user_id: index,
      name: name.to_s,
      created_at: Time.new + index.days,
      team_id: nil,
      score: score,
      data: data
    )
  end

  @@index = 0


  def self.new_item(context,**args)
    @@index+=1
    enrollment = new_enrollment @@index, ("A".."Z").to_a()[@@index], 100, args
    TeamBuilder::Grouping::Utils::Item.new enrollment, @@index, context
  end

  def self.age_items context, amount = 8, split =2
    enrollments = []
    amount.times do |index|
      enrollments << new_enrollment(index, index, 100, age: AGE[index%split])
    end
    enrollments.map! { |enrollment| TeamBuilder::Grouping::Utils::Item.new enrollment, enrollment.name, context }
  end
end
