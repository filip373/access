class AuditLogger < Logger
  def initialize(logdev, shift_age = 0, shift_size = nil)
    super(logdev, shift_age, shift_size)
    self.formatter = proc do |severity, datetime, progname, msg|
      "#{severity} #{datetime}: [#{progname}] #{msg}\n"
    end
  end
end
