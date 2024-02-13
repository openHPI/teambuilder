class AdminUser

  def guest?
    false
  end

  def admin?
    true
  end

  def course_admin?
    true
  end

  def can_enroll?(course)
    false
  end

  def can_administer?(course)
    true
  end

  def can_submit?
    true
  end

  def enrollment(course)
    nil
  end

  def serialize
    {
      type: 'admin',
      props: nil
    }
  end

  def self.from_serialized(props)
    new
  end

end
