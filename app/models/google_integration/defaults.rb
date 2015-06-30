module GoogleIntegration
  class Defaults
    def defaults
      @@defaults ||= Hashie::Mash.new(defaults_hash)
    end

    def defaults_hash
      return {} unless File.file?(Defaults.default_yaml)
      YAML.load_file(Defaults.default_yaml)
    end
    private

    def self.default_yaml
      Rails.root.join(AppConfig.permissions_repo.checkout_dir, 'google_defaults.yml')
    end

    def self.method_missing(method)
      new.defaults[method] || (yield if block_given?)
    end
  end
end
