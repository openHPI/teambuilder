module TeamBuilder
  module CourseFeatures

    class AcceptTerms
      def self.from_database(record)
        new record['value']
      end

      def initialize(terms)
        @terms = terms
      end

      def with_group_settings(_settings, _priority)
        self.class.new @terms
      end

      def type
        'accept_terms'
      end

      def text
        @terms
      end

      def to_s
        @terms
      end

      def valid_submission?(params)
        if params['accept_terms'].nil?
          errors['accept_terms'] = 'You need to accept the terms of service.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        nil
      end

      def saved(enrollment)
        { accept_terms: true }
      end

      def sort_options
        {}
      end

      def qualifiers_for(submission)
        []
      end

      def facts_for(members)
        nil
      end

      class Default
        def text
          ''
        end
      end
    end

  end
end
