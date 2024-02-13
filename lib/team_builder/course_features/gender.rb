module TeamBuilder
  module CourseFeatures

    class Gender < Feature
      GENDERS = %w[
        male
        female
      ]

      def max_value
        1
      end

      def average(values)
        valueaverage = 0.0;
        values.each do |value|
          valueaverage += GENDERS.index(value.to_s)
        end
        valueaverage/values.length
      end

      def value_of(part)
        part.data['gender'].to_s
      end

      def distance(values1, values2)
        average(values1) - average(values2)
      end

      def valid_submission?(params)
        unless GENDERS.include? params['gender'].to_s
          errors['gender'] = 'Please select your gender.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { gender: params['gender'] }
      end

      def saved(enrollment)
        { gender: enrollment.data['gender'] }
      end

      def sort_options
        {}
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << {text: submission['gender']} if submission['gender']
        end
      end

      def facts_for(members)
        genders = members.map{ |member| member.data['gender'] }.uniq

        if diverse?
          if genders.count > 1
            ['green', 'Diverse gender']
          else
            ['red', genders.first]
          end
        else
          if genders.count == 1
            ['green', genders.first]
          else
            ['red', 'Mixed gender']
          end
        end
      end

      def type
        'group_by_gender'
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
