require 'team_builder/platforms'

class Platform

  class << self
    def find(id)
      cache[id] ||= make id
    end

    def all
      Settings.platforms.map(&:name)
    end

    private

    def make(id)
      settings = Settings['platforms'].find { |platform|
        platform['name'] == id
      } or raise KeyError, 'Invalid platform ID'

      TeamBuilder::Platforms.make settings
    end

    def cache
      @cache ||= {}
    end
  end

end
