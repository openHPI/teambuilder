module TeamBuilder
  module CourseFeatures

    class Feature

      def initialize(priority = 1.0, weight = 1.0, diversity = 'similar')
        @priority = priority
        @weight = weight
        @diversity = diversity
      end

      def self.from_database(record)
        new 1.0, 1.0, record['value']
      end

      def to_s
        @diversity
      end

      def with_group_settings(settings, priority = 1.0, weight = 1.0)
        self.class.new priority, weight, settings['diversity']
      end

      def priority
        @priority ||= 1.0
      end

      def priority=(priority)
        @priority = priority
      end

      def weight
        @weight ||= 1.0
      end

      def weight=(weight)
        @weight = weight
      end

      def similar?
        @diversity == 'similar'
      end

      def diverse?
        not similar?
      end

      def max_value
        raise NotImplementedError
      end

      def distance(values1, values2)
        raise NotImplementedError
      end

      def type
        raise NotImplementedError
      end

      def name_as_sym
        type
      end

      def distance_between(values1, values2)
        if similar?
          distance(values1, values2).abs.to_f/(max_value)*weight*(1000**priority)
        else
          (max_value-distance(values1, values2).abs).to_f/(max_value)*weight*(1000**priority)
        end
      end
    end
  end
end
