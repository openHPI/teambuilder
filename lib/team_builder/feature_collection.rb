require 'forwardable'
require 'team_builder/course_features'

module TeamBuilder
  class FeatureCollection

    include Enumerable
    extend Forwardable
    def_delegators :@features_array, :each, :<<

    def initialize(features, grouping_enabled = [])
      @features_array = features
      @grouping = grouping_enabled
    end

    def enabled?(type)
      @features_array.any? { |feature| feature.type == type }
    end

    def grouping_enabled?(type)
      @grouping.include? type
    end

    def fetch(type)
      @features_array.find { |feature| feature.type == type } || CourseFeatures.default(type)
    end

    def enrollment_data(enrollment)
      map { |feature| feature.saved(enrollment) }.compact.inject({}, :merge)
    end

    def data_from_params(params)
      map { |feature| feature.submission(params) }.compact.reduce({}, :merge)
    end

    def valid?(params)
      all? { |feature| feature.valid_submission?(params) }
    end

    def errors
      map(&:errors).compact.reduce({}, :merge)
    end

    def sort_options
      @features_array.map(&:sort_options).reduce({}, :merge)
    end

    def facts_for(members)
      map{ |feature| feature.facts_for members }.compact
    end

    def qualifiers_for(enrollment)
      map{ |feature| feature.qualifiers_for enrollment.data }.flatten
    end

    def only_grouping_enabled
      self.class.new(
        @features_array.select { |feature| @grouping.include? feature.type },
        @grouping
      )
    end

    def with_group_settings(enabled, settings)
      enabled = ['timezone'] + enabled

      self.class.new(
        @features_array.map { |feature|
          feature_settings = settings[:features][feature.type] || {}
          index = enabled.index(feature.type)
          priority = index ? enabled.length - index : 0
          feature.with_group_settings feature_settings, priority
        },
        enabled
      )
    end

    def calculate_distance(value1, value2)
      distance = 0.0
      each do |feature|
        # For features that should be clustered similarly:
        # 1.The distance of the 2 Values is calculated
        # 2.The distance is divided by the max distance of that feature (normalization)
        # 3.The distance is multiplied by the features weight
        # 4.The distance is multiplied by 1000 to the power of the features priority. Essentially priorities are nothing else than extreme weights.
        # If the feature should be clustered diverse the process is the exact same except the distance value is inverted at the beginning.
        # So that objects further away from each other are now closer to each other. (i.e. distance: 0.9 becomes 0.1 etc.)

        feature_values1 = value1.raw_values[feature.name_as_sym]
        feature_values2 = value2.raw_values[feature.name_as_sym]
        distance += feature.distance_between(feature_values1, feature_values2)
      end
      distance
    end

    def method_missing(method)
      if method.to_s.ends_with? '?'
        public_send :enabled?, method.to_s[0...-1]
      else
        public_send :fetch, method.to_s
      end
    end

  end
end
