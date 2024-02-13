require 'active_support/all'

module TeamBuilder
  module CourseFeatures

    class Timezone < Feature
      # A hash of timezones
      # Mapping from UTC offset (in seconds) to a pretty name (offset + important places)
      TIMEZONES = Hash[ActiveSupport::TimeZone.all.group_by(&:utc_offset).map { |offset, tz|
        formatted_offset = tz.first.formatted_offset
        names = tz.map(&:name).join ', '
        ["#{offset}", "GMT#{formatted_offset} (#{names})"]
      }]

      def self.from_database(_record)
        new
      end

      def initialize(group_type = 'same_timezone', priority = 1.0, weight = 1.0, diversity = 'similar')
        @grouping_type = group_type
        super priority, weight, diversity
      end

      def with_group_settings(settings, priority = 1.0, weight = 1.0, diversity = 'similar')
        if settings[:type] == 'local_teams'
          TeamBuilder::CourseFeatures::LocalTeams.new settings[:max_distance], priority, weight, diversity
        else
          self.class.new settings[:type], priority, weight, diversity
        end
      end

      def type
        'timezone'
      end

      def grouping_type
        @grouping_type ||= 'same_timezone'
      end

      def grouping_type=(type)
        @grouping_type = type
      end

      def valid_submission?(params)
        unless TIMEZONES.has_key? params['time_zone']
          errors['time_zone'] = 'Please select a valid timezone.'
          return false
        end

        true
      end

      def average(values)
        normalizedvalues = values.map{ |value| (value+43200)*(Math::PI/86400)}
        sines = normalizedvalues.reduce(0.0) {|sum, value| sum + Math::sin(value)}
        cosines = normalizedvalues.reduce(0.0) {|sum, value| sum + Math::cos(value)}
        averageangle = Math::atan2(1.0/values.length * sines, 1.0/values.length * cosines)
        averageangle = (averageangle/Math::PI * 86400) - 43200
        averageangle
      end

      def max_value
        12
      end

      def value_of(participant)
        participant.data['timezone'].to_i
      end

      def distance(values1, values2)
        average(values1)/3600 - average(values2)/3600
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { timezone: params['time_zone'] }
      end

      def saved(enrollment)
        { time_zone: enrollment.data['timezone'] }
      end

      def sort_options
        {
          'timezone' => SortByTimezone.new(self)
        }
      end

      def facts_for(members)
        return if members.empty? # no facts for empty teams
        # Offset from GMT in seconds
        offsets = members.map { |member| member.data['timezone'].to_i }

        time_diff = max_time_diff offsets

        if time_diff <= 2.0 # Maximum distance of two hours
          timezones = offsets.uniq.sort

          if time_diff == 0.0 # Only one timezone
            ['green', format_timezone(timezones.first)]
          elsif time_diff == 2.0 # Show the one in the middle
            ['green', "... #{format_timezone((timezones.last + timezones.first) / 2)} ..."]
          else
            ['green', "#{format_timezone(timezones.first)} ..."]
          end
        elsif time_diff <= 4.0
          ['yellow', "Time difference: #{'%g' % time_diff}h"]
        else
          ['red', "Time difference: #{'%g' % time_diff}h"]
        end
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << {text: 'GMT' + ActiveSupport::TimeZone[submission['timezone'].to_i].formatted_offset} if submission['timezone']
        end
      end

      def bucketize(bucket)
        sorted = bucket.sort_by { |item| item.data['timezone'].to_i }

        start_timezone = nil
        current_bucket = []
        buckets = []
        sorted.each do |item|
          tz = item.data['timezone'].to_i

          start_timezone = tz if start_timezone.nil?

          if start_timezone + 7200 < tz
            start_timezone = tz
            buckets << current_bucket.shuffle
            current_bucket = []
          end

          current_bucket << item
        end

        current_bucket.shuffle! if grouping_type == 'culturally_diverse'
        buckets << current_bucket

        buckets
      end

      def format_timezone(offset)
        'GMT' + ActiveSupport::TimeZone[offset].formatted_offset
      end

      def max_time_diff(offsets)
        # Normalize negative offsets to deal with the International Date Line
        shifted_offsets = offsets.map { |offset| offset % 86400 }

        [
          ((offsets.max - offsets.min) / 3600.0).round(1),
          ((shifted_offsets.max - shifted_offsets.min) / 3600.0).round(1)
        ].min
      end

      Default = Timezone

      class SortByTimezone
        def initialize(feature)
          @feature = feature
        end

        def to_s
          'Timezone'
        end

        def sort(a, b)
          # sorting for empty teams: displaying empty teams at the bottom
          return 0 if a.members.empty? and b.members.empty?
          return 1 if a.members.empty?
          return -1 if b.members.empty?

          a_offsets = a.members.map { |member| member.data['timezone'].to_i }
          b_offsets = b.members.map { |member| member.data['timezone'].to_i }

          a_diff = @feature.max_time_diff a_offsets
          b_diff = @feature.max_time_diff b_offsets

          # Make sure red teams appear first.
          if a_diff > 4.0 || b_diff > 4.0
            [b_diff, a_offsets.min] <=> [a_diff, b_offsets.min]
          # Remaining (yellow and green) teams are sorted by minimum timezone.
          else
            a_offsets.min <=> b_offsets.min
          end
        end
      end
    end

  end
end
