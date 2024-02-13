module Routing
  extend ActiveSupport::Concern
  include Rails.application.routes.url_helpers

  included do
    def default_url_options
      {
        host: Settings['host']
      }.tap { |options|
        options[:protocol] = 'https' if Settings['https']
      }
    end
  end
end
