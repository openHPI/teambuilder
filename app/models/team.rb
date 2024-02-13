class Team < ApplicationRecord

  belongs_to :course
  has_many :members, class_name: 'Enrollment', dependent: :nullify

  scope :empty, -> { includes(:members).where(enrollments: { team_id: nil }) }

  validates_presence_of :name

  class SortByName
    def to_s
      'Name'
    end

    def sort(a, b)
      a.name.upcase <=> b.name.upcase
    end
  end

  class SortBySize
    def to_s
      'Size'
    end

    def sort(a, b)
      a.members.count <=> b.members.count
    end
  end

end
