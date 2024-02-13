module TeamBuilder::Platforms

  class Dummy
    class << self
      def make(config)
        new config['name']
      end
    end

    def initialize(name)
      @name = name
    end

    attr_reader :name

    def oauth_credentials?
      false
    end

    def courses?
      false
    end

    def check_scores?
      true
    end

    def user_scores(course)
      course.enrollments.inject({}) { |hash, enrollment|
        # Generate random team scores
        hash[enrollment.user_id] = rand 0.0..100.0
        hash
      }
    end

    def user_link?
      false
    end

    def collab_spaces?
      true
    end

    def create_collab_spaces(teams)
      Rails.logger.info 'Exporting teams to collab spaces'
      teams.each do |team|
        Rails.logger.info "Exporting team #{team.inspect}"
      end
    end

    def collab_space_link?
      false
    end
  end

end
