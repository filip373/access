require 'active_support/core_ext'
require 'konf'

config_path = File.expand_path('../config.yml', __FILE__)
sec_config_path = File.expand_path('../sec_config.yml', __FILE__)

pub_config = YAML.load(File.read(config_path))[Rails.env] || {}
sec_config = if File.exist?(sec_config_path)
               YAML.load(File.read(sec_config_path))[Rails.env] || {}
             else
               {}
             end

AppConfig = Konf.new(pub_config.deep_merge(sec_config))
