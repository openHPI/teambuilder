require 'team_builder/feature_collection'

module TeamBuilder
  module CourseFeatures

    require 'team_builder/course_features/feature'
    require 'team_builder/course_features/language_teams'
    require 'team_builder/course_features/timezone'
    require 'team_builder/course_features/preferred_tasks'
    require 'team_builder/course_features/commitment'
    require 'team_builder/course_features/local_teams'
    require 'team_builder/course_features/area_of_expertise'
    require 'team_builder/course_features/gender'
    require 'team_builder/course_features/age'
    require 'team_builder/course_features/accept_terms'

    # These are ordered by their priority for grouping
    # E.g. spoken language will always be used for group
    # assignments before the timezone is considered.
    SUPPORTED_FEATURES = {
      'language_teams' => LanguageTeams,
      'timezone' => Timezone,
      'preferred_tasks' => PreferredTasks,
      'group_by_commitment' => Commitment,
      'local_teams' => LocalTeams,
      'group_by_expertise' => AreaOfExpertise,
      'group_by_gender' => Gender,
      'group_by_age' => Age,
      'accept_terms' => AcceptTerms
    }

    class << self
      def wrap(features)
        unless features.is_a? TeamBuilder::FeatureCollection
          features = TeamBuilder::FeatureCollection.new(features)
        end

        features
      end

      def from_database(features)
        TeamBuilder::FeatureCollection.new(
          enabled(features), grouping_enabled(features)
        )
      end

      def default(type)
        klass_from_type(type)::Default.new
      end

      private

      def klass_from_type(type)
        SUPPORTED_FEATURES.fetch(type) do
          raise ArgumentError.new 'Invalid course feature type'
        end
      end

      def enabled(features)
        features.map do |f|
          next unless SUPPORTED_FEATURES.include? f['type']

          klass_from_type(f['type']).from_database f
        end.compact.tap do |types|
          # Timezone is always enabled; return/abort if already set
          next types if types.any? {|t| t.type == 'timezone' }

          types << klass_from_type('timezone').from_database(nil)
        end
      end

      def grouping_enabled(features)
        features.select { |f| f['grouping_enabled'] }.map { |f| f['type'] }
      end
    end

  end
end
