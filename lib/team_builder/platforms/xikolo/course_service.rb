module TeamBuilder::Platforms
  module Xikolo

    class CourseService
      def initialize(url)
        @url = url
      end

      def available_courses
        root.rel(:courses).get(per_page: 100, affiliated: true)
          .value
          .sort_by { |course| course['title'] }
      end

      private

      def root
        @root ||= Restify.new(@url).get.value
      end
    end

  end
end

