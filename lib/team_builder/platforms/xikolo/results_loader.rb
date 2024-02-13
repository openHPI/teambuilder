module TeamBuilder::Platforms
  module Xikolo

    class ResultsLoader
      def initialize(course_url)
        @course_url = course_url
      end

      def user_scores(course)
        total_points = 0.0
        user_points = Hash.new(0.0)

        each_relevant_item(course) do |item|
          total_points += item['max_points']
          merge_item_user_points(item, user_points)
        end

        percentage_of(total_points, user_points)
      end

      private

      # Fetch and yield all eligible items.
      #
      # Eligible items are those with points, with a deadline that has already passed.
      def each_relevant_item(course)
        paginate(
          course_root.rel(:items).get(
            course_id: course.id,
            exercise_type: 'main',
            was_available: true
          )
        ) do |item|
          next unless item['max_points'].is_a?(Float)
          next if item['submission_deadline'] && DateTime.parse(item['submission_deadline']).future?

          yield item
        end
      end

      def merge_item_user_points(item, user_points)
        paginate(
          item.rel(:results).get(
            item_id: item['id'],
            best_per_user: true
          )
        ) do |result|
          # Accumulate the achieved points for each user
          user_points[result['user_id']] += result['points']
        end
      end

      # Turn the number of points achieved by each user into a percentage of
      # possible points.
      def percentage_of(total_points, user_points)
        # Prevent a division by zero if no items were found
        return {} if total_points == 0.0

        user_points.transform_values { |points|
          (points / total_points) * 100
        }
      end

      def course_root
        @course_root ||= Restify.new(@course_url).get.value
      end

      def paginate(first_request, &block)
        current_page = first_request.value!

        loop do
          current_page.each do |item|
            block.call item, current_page
          end

          break unless current_page.rel?(:next)

          current_page = current_page.rel(:next).get.value!
        end
      end
    end

  end
end

