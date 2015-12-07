class BufferedLogDevice < Logger::LogDevice
  attr_accessor :buffer

  def initialize(_log = nil, opts = {})
    super('/dev/null', opts)
    @buffer = ''
  end

  def write(message)
    @buffer << message
  end
end
