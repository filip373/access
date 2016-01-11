class AuditedApi
  attr_reader :object, :user, :logger

  def initialize(object, user, logger = AuditLogger.new(Rails.root.join('log', 'audit.log')))
    @object = object
    @user = user
    @logger = logger
  end

  def method_missing(*args)
    method_name = args.shift
    response = object.public_send(method_name, *args)
    message = transform_action_to_log(method_name, response, args).push(object.namespace)
    logger.add(*message)
    response
  end

  def respond_to_missing?(method, *)
    @object.respond_to?(method)
  end

  private

  def transform_action_to_log(method_name, response, arguments)
    args = map_arguments(method_name, arguments)
    result = response.nil? ? 'ERROR' : 'OK'
    log_content = I18n.t(method_name, args.merge(raise: true))
    [Logger::ERROR, "#{username} -- #{result} -- #{log_content}"]
  rescue I18n::MissingTranslationData, I18n::MissingInterpolationArgument => e
    return [Logger::WARN, "#{username} -- #{e}"] if Rails.env.production?
    raise e
  end

  def get_method_signature(method_name)
    object.method(method_name).parameters.map(&:last).flatten
  end

  def map_arguments(method_name, arguments)
    attr_names = get_method_signature(method_name)
    Hash[attr_names.zip(arguments.map { |arg| get_arg_value(arg) })].merge(scope: object.namespace)
  end

  def status_code(response)
    response.try(:code) || response.try(:status_code)
  end

  def get_arg_value(arg)
    arg.try(:name) || arg.try(:default_email) || arg.to_s
  end

  def username
    @user.email || @user.name
  end
end
