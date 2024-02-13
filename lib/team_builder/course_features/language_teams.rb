module TeamBuilder
  module CourseFeatures

    class LanguageTeams < Feature
      LANGUAGES = %w[
        Arabic
        Chinese
        English
        French
        German
        Portuguese
        Russian
        Spanish
      ]

      def max_value
        1
      end

      def value_of(participant)
        participant.data['language'].to_s
      end

      def distance(values1, values2)
        distance = 0.0
        values1.each do |language1|
          individual_distance = 0.0
          values2.each do |language2|
            if LANGUAGES.index(language1.to_s) == LANGUAGES.index(language2.to_s)
              individual_distance += 0
            else
              individual_distance += 1
            end
          end
          distance += individual_distance/values2.length
          end
        distance/values1.length
      end

      def type
        'language_teams'
      end

      def valid_submission?(params)
        unless LANGUAGES.include? params['preferred_language'].to_s
          errors['preferred_language'] = 'Please select a preferred language.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { language: params['preferred_language'] }
      end

      def saved(enrollment)
        { preferred_language: enrollment.data['language'] }
      end

      def sort_options
        {
          'language' => SortByLanguage.new(self)
        }
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << { text: submission['language'] } if submission['language']
        end
      end

      def facts_for(members)
        languages = members.map{ |member| member.data['language'] }.uniq

        if diverse?
          if languages.count == 1
            ['red', languages.first]
          elsif languages.count == 2
            ['yellow', languages.sort.join(', ')]
          else
            ['green', 'Different languages']
          end
        else
          if languages.count == 1
            ['green', languages.first]
          elsif languages.count == 2
            ['yellow', languages.sort.join(', ')]
          else
            ['red', 'Different languages']
          end
        end
      end

      def bucketize(bucket)
        bucket.group_by { |item| item.data['language'] }.values
      end

      class Default; end

      class SortByLanguage
        def initialize(feature)
          @feature = feature
        end

        def to_s
          'Language'
        end

        def sort(a, b)
          a_facts = @feature.facts_for(a.members)
          b_facts = @feature.facts_for(b.members)

          # Move teams with more than two languages to the end
          return 1 if a_facts[0] == 'red'
          return -1 if b_facts[0] == 'red'

          # By default, sort displayed languages alphabetically
          a_facts[1] <=> b_facts[1]
        end
      end
    end

  end
end
