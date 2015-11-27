module TogglIntegration
  class Task
    attr_reader :name, :pid

    def initialize(name:, pid:)
      @name = name
      @pid = pid
    end

    def name?
      !name.nil?
    end

    def project_id?
      !pid.nil?
    end

    def ==(other)
      return false unless self.class == other.class
      name == other.name && pid == other.pid
    end

    def eql?(other)
      self == other
    end

    def hash
      [name, pid].hash
    end
  end
end
