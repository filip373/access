module GoogleIntegration
  class Defaults

    attr_reader :defaults

    def initialize
      defaults_hash = if File.file?(Defaults.default_yaml)
        YAML.load_file(Defaults.default_yaml)
      else
        {}
      end

      @defaults = Hashie::Mash.new(defaults_hash)
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
