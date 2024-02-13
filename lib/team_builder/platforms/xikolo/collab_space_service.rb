module TeamBuilder::Platforms
  module Xikolo

    class CollabSpaceService
      def initialize(url)
        @url = url
      end

      def create!(team)
        # Avoid creating collab spaces for left-over empty teams
        return if team.members.empty?

        # Create new collab space
        root.rel(:collab_spaces).post(
          name: team.name,
          course_id: team.course_id,
          is_open: false,
          kind: 'team'
        ).value!.tap do |space|
          # Assign members to the room
          team.members.map { |member|
            space.rel(:memberships).post(
              user_id: member.user_id,
              status: 'admin'
            )
          }.map(&:value!)
        end
      end

      private

      def root
        @root ||= Restify.new(@url).get.value
      end
    end

  end
end

