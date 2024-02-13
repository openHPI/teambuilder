require 'geocoder'

module TeamBuilder
  module CourseFeatures

    class LocalTeams < Feature
      def self.from_database(record)
        new record['value']
      end

      def initialize(distance, priority = 1.0, weight = 1.0, diversity = 'similar')
        @distance = distance
        super priority, weight, diversity
      end

      def with_group_settings(settings, priority = 1.0, weight = 1.0)
        self.class.new settings['max_distance'], priority, weight
      end

      def type
        'local_teams'
      end

      def max_distance
        @distance.to_i
      end

      def to_s
        @distance
      end

      def valid_submission?(params)
        if params['location_lat'].to_s.empty? || params['location_lng'].to_s.empty?
          errors['location'] = 'Please enter or select your location.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        {
          location: {
            latitude: params['location_lat'],
            longitude: params['location_lng'],
            text: params['location']
          }
        }
      end

      def saved(enrollment)
        {
          location_lat: enrollment.data['location']['latitude'],
          location_lng: enrollment.data['location']['longitude'],
          location: enrollment.data['location']['text']
        }
      end

      def sort_options
        {
          'distance' => SortByDistance.new(self)
        }
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          if submission['location'].is_a? Hash
            exact = "LAT/LNG: #{submission['location']['latitude']}/#{submission['location']['longitude']}"

            if submission['location']['text']
              arr << {text: submission['location']['text'], detail: exact}
            else
              arr << {text: exact}
            end
          end
        end
      end

      def facts_for(members)
        max = calc_max_distance(members)

        pretty_distance = "Max distance: #{max.round} km"

        if max <= max_distance
          ['green', pretty_distance]
        elsif max <= 2 * max_distance
          ['yellow', pretty_distance]
        else
          ['red', pretty_distance]
        end
      end

      def bucketize(bucket)
        DBSCAN(
          bucket.map { |item|
            [
              item.data['location']['latitude'].to_f,
              item.data['location']['longitude'].to_f
            ]
          },
          epsilon: Geocoder::Calculations::to_nautical_miles(@distance.to_i),
          min_points: 1,
          distance: :haversine_distance2,
          labels: bucket
        ).clusters.values.map{ |cluster| cluster.map(&:label) }.select{ |b| b.size > 0 }
      end

      def max_value
        20037
      end

      def value_of(participant)
        [participant.data['location']['latitude'].to_f,
         participant.data['location']['longitude'].to_f]
      end

      def distance(values1, values2)
        distance= 0.0
        values1.each do |val1|
          individual_distance = 0.0
          values2.each do |val2|
            individual_distance += Geocoder::Calculations::distance_between(val1, val2).to_f * (1.0/Geocoder::Calculations::KM_IN_NM)
          end
          distance+=individual_distance/values2.length
        end
        distance/values1.length
      end

      def calc_max_distance(members)
        points = members.map { |member|
          [member.data['location']['latitude'].to_f, member.data['location']['longitude'].to_f]
        }

        pairs = points.uniq.combination(2).to_a

        calc_distance = lambda { |pair|
          Geocoder::Calculations::distance_between( pair[0], pair[1] )
        }

        pairs.map(&calc_distance).max.to_f * 1.0/Geocoder::Calculations::KM_IN_NM
      end

      class Default
        def max_distance
          50
        end
      end

      class SortByDistance
        def initialize(feature)
          @feature = feature
        end

        def to_s
          'Distance'
        end

        def sort(a, b)
          @feature.calc_max_distance(a.members) <=> @feature.calc_max_distance(b.members)
        end
      end
    end

  end
end
