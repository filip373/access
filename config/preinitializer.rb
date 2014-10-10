require 'active_support/core_ext'
require 'konf'
require 'pry'

config_path = File.expand_path('../config.yml', __FILE__)
sec_config_path = File.expand_path('../sec_config.yml', __FILE__)

pub_config = YAML.load(ERB.new(File.read(config_path)).result)[Rails.env] || {}
sec_config = File.exist?(sec_config_path) ? YAML.load(ERB.new(File.read(sec_config_path)).result)[Rails.env] : {}

AppConfig = Konf.new(pub_config.deep_merge(sec_config || {}))
