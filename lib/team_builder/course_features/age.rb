module TeamBuilder
  module CourseFeatures

    class Age < Feature
      GROUPS = [
        '1-19',
        '20-29',
        '30-39',
        '40-49',
        '50-59',
        '60-69',
        '70 and older'
      ]

      def valid_submission?(params)
        unless GROUPS.include? params['age'].to_s
          errors['age'] = 'Please select your age.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { age: params['age'] }
      end

      def saved(enrollment)
        { age: enrollment.data['age'] }
      end

      def sort_options
        {}
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << {text: "Age: #{submission['age']}"} if submission['age']
        end
      end

      def facts_for(members)
        age_groups = members.map{ |member| member.data['age'] }.uniq.count

        if diverse?
          if age_groups >= 3
            ['green', 'Diverse age']
          else
            ['red', 'Homogeneous age']
          end
        else
          if age_groups == 1
            ['green', 'Same age']
          elsif age_groups <= 3
            ['yellow', 'Similar age']
          else
            ['red', 'Mixed age']
          end
        end
      end

      def max_value
        GROUPS.length-1
      end

      def value_of(participant)
        participant.data['age'].to_s
      end

      def average(values)
        valueaverage = 0.0
        values.each do |value|
          valueaverage += GROUPS.index(value.to_s)
        end
        valueaverage/values.length
      end

      def distance(values1, values2)
        average(values1) - average(values2)
      end

      def bucketize(bucket)
        bucket.group_by { |item| item.data['age'] }.values
      end

      def type
        'group_by_age'
      end

      class Default
        def similar?
          true
        end

        def diverse?
          false
        end
      end
    end

  end
end
