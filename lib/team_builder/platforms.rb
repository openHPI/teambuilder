module TeamBuilder
  module Platforms

    require 'team_builder/platforms/dummy'
    require 'team_builder/platforms/xikolo'

    class << self
      def make(settings)
        {
          'dummy' => Platforms::Dummy,
          'xikolo' => Platforms::Xikolo
        }.fetch(settings['type']).make(settings)
      end
    end

  end
end
