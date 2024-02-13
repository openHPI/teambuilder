class User

  class << self
    def from_serialized(data)
      klass_for(data['type']).from_serialized data['props']
    end

    private

    def klass_for(type)
      case type
        when 'lti'
          LtiUser
        when 'admin'
          AdminUser
        else
          GuestUser
      end
    end
  end

end
