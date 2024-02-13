module TeamBuilder::Platforms
  module Xikolo

    require 'team_builder/platforms/xikolo/collab_space_service'
    require 'team_builder/platforms/xikolo/course_service'
    require 'team_builder/platforms/xikolo/results_loader'

    class Adapter
      def initialize(config = {})
        @services = config['services'].to_h.stringify_keys || {}
        @name = config['name']
        @oauth = config['oauth'].to_h.stringify_keys
      end

      attr_reader :name

      def oauth_credentials?
        true
      end

      def oauth_credentials
        {
          key: @oauth.fetch('key'),
          secret: @oauth.fetch('secret'),
        }
      end

      def courses?
        service_enabled? 'course'
      end

      def check_scores?
        service_enabled?('course')
      end

      def user_scores(course)
        results.user_scores course
      end

      def user_link?
        service_enabled? 'web'
      end

      def user_link(user)
        "#{@services['web']}/users/#{user.user_id}"
      end

      def courses
        course_service.available_courses
      end

      def collab_spaces?
        service_enabled? 'collab_space'
      end

      def create_collab_space(team)
        collab_space = collab_space_service.create! team

        team.update collab_space_id: collab_space['id']
      end

      def create_collab_spaces(teams)
        teams.each do |team|
          create_collab_space team
        end
      end

      def collab_space_link?
        service_enabled? 'web'
      end

      def collab_space_link(team)
        "#{@services['web']}/courses/#{team.course_id}/learning_rooms/#{team.collab_space_id}"
      end

      private

      def service_enabled?(name)
        @services.has_key? name
      end

      def course_service
        @course_service ||= CourseService.new @services['course']
      end

      def results
        @results ||= ResultsLoader.new @services['course']
      end

      def collab_space_service
        @collab_space_service ||= CollabSpaceService.new @services['collab_space']
      end
    end

  end
end

