require File.expand_path('../boot', __FILE__)

require 'konf'
require "action_controller/railtie"
require 'sprockets/railtie'

require_relative 'preinitializer'


Bundler.require(*Rails.groups)

module GithubApp
  class Application < Rails::Application
    config.assets.enabled = true
  end
end
