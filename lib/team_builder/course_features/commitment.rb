module TeamBuilder
  module CourseFeatures

    class Commitment < Feature
      GROUPS = [
        '1-2 Hours',
        '3-4 Hours',
        '5-6 Hours'
      ]

      def valid_submission?(params)
        unless GROUPS.include? params['commitment'].to_s
          errors['commitment'] = 'Please select how much time you plan on investing.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { commitment: params['commitment'] }
      end

      def saved(enrollment)
        { commitment: enrollment.data['commitment'] }
      end

      def sort_options
        {}
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << {text: "Commitment: #{submission['commitment']}"} if submission['commitment']
        end
      end

      def facts_for(members)
        commitment_groups = members.map{ |member| member.data['commitment'] }.uniq.count

        if diverse?
          if commitment_groups >= 3
            ['green', 'Diverse Commitment']
          elsif commitment_groups == 2
            ['yellow', 'Similar Commitment']
          else
            ['red', 'Same Commitment']
          end
        else
          if commitment_groups == 1
            ['green', 'Same Commitment']
          elsif commitment_groups <= 2
            ['yellow', 'Similar Commitment']
          else
            ['red', 'Mixed Commitment']
          end
        end
      end

      def type
        'group_by_commitment'
      end

      def bucketize(bucket)
        bucket.group_by { |item| item.data['commitment'] }.values
      end

      def value_of(participant)
        participant.data['commitment'].to_s
      end

      def max_value
        GROUPS.length-1
      end

      def distance(values1, values2)
        average(values1)-average(values2)
      end

      def average(values)
        valueaverage = 0.0;
        values.each do |value|
          valueaverage += GROUPS.index(value.to_s)
        end
        valueaverage/values.length
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
