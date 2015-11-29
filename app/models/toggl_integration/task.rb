module TogglIntegration
  class Task
    attr_reader :name, :pid, :id

    def initialize(name:, pid:, id: nil)
      @name = name
      @pid = pid
      @id = id
    end

    def task_id?
      !id.nil?
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
