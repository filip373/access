class AuditedApi
  attr_reader :object, :logger

  def initialize(object, logger = AuditLogger.new(Rails.root.join('log', 'audit.log')))
    @object = object
    @logger = logger
  end

  def method_missing(*args)
    method_name = args.shift
    response = object.public_send(method_name, *args)
    logger.info(object.class.to_s) do
      <<-EOS
Called method: #{method_name}(#{get_method_signature(method_name)})
  With args:    #{format_args(args)}
  Got response: #{format_response(response)}
      EOS
    end
    response
  end

  private

  def get_method_signature(method_name)
    object.method(method_name).parameters.map(&:last).flatten.join(', ')
  end

  def format_args(args)
    args.map do |arg|
      [arg.try(:id), arg.try(:name) || arg].compact.join('#')
    end.join(', ')
  end

  def format_response(response)
    return 'Error' unless response
    status_code = response.try(:code) || response.try(:status_code) || response.try(:status)
    body = response.try(:body) || response.to_s
    [status_code, body].compact.join(', ')
  end
end
