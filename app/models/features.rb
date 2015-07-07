class Features
  @features = HashWithIndifferentAccess.new(AppConfig.features? && AppConfig.features.to_h)

  class << self
    attr_private :features

    def on?(feature_name)
      features.fetch(feature_name) { false }
    end

    def off?(feature_name)
      !on?(feature_name)
    end
  end
end
