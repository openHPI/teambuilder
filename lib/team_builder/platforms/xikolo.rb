module TeamBuilder::Platforms

  require 'team_builder/platforms/xikolo/adapter'

  module Xikolo
    class << self
      def make(config)
        Xikolo::Adapter.new config
      end
    end
  end

end
