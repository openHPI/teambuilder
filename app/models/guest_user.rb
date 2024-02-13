class GuestUser

  def guest?
    true
  end

  def admin?
    false
  end

  def course_admin?
    false
  end

  def can_enroll?(course)
    false
  end

  def can_administer?(course)
    false
  end

  def serialize
    {
      type: 'guest',
      props: nil
    }
  end

  def self.from_serialized(props)
    new
  end

end
