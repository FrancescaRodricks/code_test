require_relative 'boot'

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(*Rails.groups)


module MoneySuperMarket
  class Application < Rails::Application
    config.load_defaults 5.1

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.active_record.sqlite3.represent_boolean_as_integer = true

    config.autoload_paths += %W[#{config.root}/app/services]
  end
end
