module TogglIntegration
  class Task
    attr_reader :id, :name, :pid, :wid

    def initialize(id: nil, name:, pid:, wid: nil)
      @name = name
      @pid = pid
      @wid = wid
      @id = id
    end

    def name?
      !name.nil?
    end

    def ==(other)
      return false unless self.class == other.class
      name == other.name && pid == other.pid
    end

    def eql?(other)
      self == other
    end

    def hash
      [id, name, pid, wid].hash
    end
  end
end
