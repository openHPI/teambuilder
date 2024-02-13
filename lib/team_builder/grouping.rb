module TeamBuilder
  module Grouping

    require 'team_builder/grouping/distance_algorithm'
    require 'team_builder/grouping/dynamic_algorithm'
    require 'team_builder/grouping/utils/bucket'
    require 'team_builder/grouping/utils/bucket_container'
    require 'team_builder/grouping/utils/bucketize_logger'
    require 'team_builder/grouping/utils/item'
    require 'team_builder/grouping/utils/clustering/cluster'
    require 'team_builder/grouping/utils/clustering/hierarchical_clustering'
    require 'team_builder/grouping/utils/clustering/kmeans_clustering'
    require 'team_builder/grouping/utils/clustering/value'

    class << self
      def start!(applicants, features, opts = {})
        # Applicants may optionally be limited by score and number
        if opts[:min_score]
          applicants = applicants.where 'score >= ?', opts[:min_score]
          applicants = applicants.order 'score DESC'
        end

        if opts[:randomize]
          applicants = applicants.order Arel.sql('RANDOM()')
        else
          applicants = applicants.order 'created_at ASC'
        end

        if opts[:max_participants]
          applicants = applicants.limit opts[:max_participants]
        end

        # Run the grouping algorithm and return the teams
        algorithm(features, opts).group! applicants
      end

      def algorithm(features, opts = {})
        if opts[:new_grouping]
          Grouping::DistanceAlgorithm.new features, opts
        else
          Grouping::DynamicAlgorithm.new features, opts
        end
      end

    end
  end
end
