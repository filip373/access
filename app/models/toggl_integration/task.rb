module TogglIntegration
  class Task
    attr_reader :id, :name, :pid, :wid

    def initialize(id: nil, name:, pid:, wid: nil)
      @name = name
      @pid = pid
      @wid = wid
      @id = id
    end

    def id?
      !id.nil?
    end

    def wid?
      !wid.nil?
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

    def to_yaml
      {
        name: name,
        members: members.map(&:id).select(&:present?) || [],
        tasks: tasks || [],
        projects: projects || [],
      }.stringify_keys.to_yaml
    end
  end
end
