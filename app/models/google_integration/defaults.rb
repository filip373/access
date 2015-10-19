module GoogleIntegration
  class Defaults
    def self.defaults
      @defaults ||= Hashie::Mash.new(defaults_hash)
    end

    def self.defaults_hash
      AppConfig.google.defaults
    end

    def self.method_missing(method)
      defaults[method] || (yield if block_given?)
    end
  end
end
