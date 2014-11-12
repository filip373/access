class YAMLValidation
  attr_accessor :errors

  Error = Struct.new(:file, :message)

  def initialize
    self.errors = []
  end

  def add_error(file, message)
    errors << Error.new(file, message)
  end
end
