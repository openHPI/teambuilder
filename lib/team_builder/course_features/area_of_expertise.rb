module TeamBuilder
  module CourseFeatures

    class AreaOfExpertise < Feature
      OPTIONS = [
        'Business and Management',
        'Computer Science and Engineering',
        'Life Science',
        'Creative Design',
        'Humanities',
        'Media',
        'Social Science',
        'Other'
      ]

      def max_value
        1
      end

      def distance(values1, values2)
        value_distance(values1, values2)
      end

      def value_of(participant)
        participant.data['area_of_expertise']
      end

      def value_distance(values1, values2)
        absolute_distance = 0.0
        values1.each do |value1|
          values2.each do |value2|
            absolute_distance += value1 == value2 ? 0 : 1
          end
        end
        absolute_distance / (values1.length*values2.length)
      end

      def valid_submission?(params)
        unless OPTIONS.include? params['area_of_expertise'].to_s
          errors['area_of_expertise'] = 'Please select your area of expertise.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { area_of_expertise: params['area_of_expertise'] }
      end

      def saved(enrollment)
        { area_of_expertise: enrollment.data['area_of_expertise'] }
      end

      def sort_options
        {}
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << {text: submission['area_of_expertise']} if submission['area_of_expertise']
        end
      end

      def facts_for(members)
        areas = members.map{ |member| member.data['area_of_expertise'] }.uniq

        if diverse?
          threshold = [(members.size * (2 / 3.0)).floor, 2].max
          if areas.count >= threshold || areas.count == OPTIONS.count
            ['green', 'Diverse expertise']
          elsif areas.count == 1
            ['red', areas.first]
          else
            ['yellow', 'Homogeneous expertise']
          end
        else
          if areas.count == 1
            ['green', areas.first]
          elsif areas.count <= 3
            ['yellow', 'Similar expertise']
          else
            ['red', 'Mixed expertise']
          end
        end
      end

      def type
        'group_by_expertise'
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
