require_relative 'boot'

require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'sprockets/railtie'

require 'csv'
require 'json'
# require 'iconv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tbuilder
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Auto and eager load library code
    config.autoload_paths += %W[#{config.root}/lib]
    config.eager_load_paths += %W[#{config.root}/lib]

    # Restify: Do not wrap hashes with object-like accessors
    Restify::Processors::Json.indifferent_access = false

    # P3P headers for iframe embeds in Internet Explorer
    config.middleware.insert_before ActionDispatch::Session::CookieStore, Rack::P3p

    # Warden configuration
    config.middleware.insert_after ActionDispatch::Flash, RailsWarden::Manager do |manager|
      # Configure Warden here
      manager.failure_app = lambda { |env|
        failure_type = env['warden.options'][:type]
        AuthController.action("fail_#{failure_type}".to_sym).call(env)
      }
      #manager.default_strategies :name

      Warden::Manager.serialize_into_session do |user|
        JSON.dump user.serialize
      end

      Warden::Manager.serialize_from_session do |serialized|
        User.from_serialized JSON.parse(serialized)
      end

      Warden::Strategies.add(:lti, LtiStrategy)
      Warden::Strategies.add(:password, PasswordStrategy)
    end
  end
end
