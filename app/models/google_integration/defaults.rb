module GoogleIntegration
  class Defaults
    def self.defaults
      @defaults ||= Hashie::Mash.new(defaults_hash)
    end

    def self.defaults_hash
      return {} unless File.file?(default_yaml)
      YAML.load_file(default_yaml)
    end
    private

    def self.default_yaml
      Rails.root.join(AppConfig.permissions_repo.checkout_dir, 'google_defaults.yml')
    end

    def self.method_missing(method)
      defaults[method] || (yield if block_given?)
    end
  end
end
