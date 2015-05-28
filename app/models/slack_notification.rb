require 'slack-notifier'

class SlackNotification
  attr_accessor :opts

  def initialize(opts = {})
    self.opts = opts
  end

  def name
    'Access app'
  end

  def ping!
    return unless configured? && opts.key?(:message)
    client.ping opts[:message]
  end

  def client
    @client ||= Slack::Notifier.new AppConfig.slack.webhook_url,
                                    channel: ['#', AppConfig.slack.default_channel].join,
                                    username: name
  end

  def configured?
    AppConfig.slack? && AppConfig.slack.webhook_url?
  end
end
