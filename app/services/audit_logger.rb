class AuditLogger < Logger
  def initialize(logdev, shift_age = 0, shift_size = nil)
    super(logdev, shift_age, shift_size)
    self.formatter = proc do |_severity, datetime, progname, msg|
      "#{datetime}: [#{progname}] #{msg}\n"
    end
  end
end
