require File.expand_path('../boot', __FILE__)

require 'konf'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

require_relative 'preinitializer'

Bundler.require(*Rails.groups)

module GithubApp
  class Application < Rails::Application
    config.assets.enabled = true
  end
end
