require 'json'

module TeamBuilder
  module CourseFeatures

    class PreferredTasks < Feature
      DEFAULT_NAME = 'Course-specific preference'.freeze

      def self.from_database(record)
        opts = JSON.parse(record['value'])

        new opts['tasks'], 1.0, 1.0, opts['diversity'], name: opts['name'], id: opts['identifier']
      end

      def initialize(tasks, priority = 1.0, weight = 1.0, diversity = 'similar', name: nil, id: nil)
        @id = id
        @name = name
        @tasks = tasks
        super priority, weight, diversity
      end

      def with_group_settings(settings, prio = 1.0, weighting = 1.0)
        self.class.new @tasks, prio, weighting, settings['diversity'], name: @name, id: @id
      end

      def type
        'preferred_tasks'
      end

      def tasks
        @tasks
      end

      def name
        @name.presence || DEFAULT_NAME
      end

      def id
        @id
      end

      def task_identifier
        return 'preferred_task' if @id.blank?

        "preferred_task_#{@id}"
      end

      def to_s
        {tasks: @tasks, diversity: @diversity, name: @name, identifier: @id}.to_json
      end

      def valid_submission?(params)
        unless params[task_identifier] && params[task_identifier].to_i.between?(0, tasks.count - 1)
          errors[task_identifier] = 'Please choose one of the options.'
          return false
        end

        true
      end

      def errors
        @errors ||= {}
      end

      def submission(params)
        { "#{task_identifier}": params[task_identifier] }
      end

      def saved(enrollment)
        { "#{task_identifier}": enrollment.data[task_identifier] }
      end

      def sort_options
        {}
      end

      def max_value
        1
      end

      def distance(values1, values2)
        value_distance(values1, values2)
      end

      def value_distance(values1, values2)
        absolute_distance = 0.0
        values1.each do |value1|
          values2.each do |value2|
            absolute_distance += value1 == value2 ? 0 : 1
          end
        end
        absolute_distance / (values1.length * values2.length)
      end

      def value_of(participant)
        participant.data[task_identifier]
      end

      def qualifiers_for(submission)
        [].tap do |arr|
          arr << { text: tasks[submission[task_identifier].to_i] } if submission[task_identifier]
        end
      end

      def facts_for(members)
        chosen_tasks = members.map { |member| member.data[task_identifier] }.uniq
        if similar?
          if chosen_tasks.count == 1
            ['green', tasks[chosen_tasks.first.to_i]]
          elsif chosen_tasks.count == 2 && tasks.count > 2
            ['yellow', chosen_tasks.map { |i| tasks[i.to_i] }.sort.join(', ')]
          else
            ['red', "#{chosen_tasks.count} tasks"]
          end
        else
          if chosen_tasks.count == 1
            ['red', tasks[chosen_tasks.first.to_i]]
          elsif chosen_tasks.count == 2 && tasks.count > 2
            ['yellow', chosen_tasks.map { |i| tasks[i.to_i] }.sort.join(', ')]
          else
            ['green', "#{chosen_tasks.count} tasks"]
          end
        end
      end

      def bucketize(bucket)
        bucket.group_by { |item| item.data[task_identifier].to_i }.values
      end

      class Default
        def tasks
          []
        end
      end
    end

  end
end
