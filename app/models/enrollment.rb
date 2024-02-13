require 'json'

class Enrollment < ApplicationRecord

  belongs_to :course, counter_cache: :enrollments_count
  belongs_to :team, optional: true

  serialize :data, JSON

end
