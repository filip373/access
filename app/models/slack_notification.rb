require 'slack-notifier'
class SlackNotification < Struct.new(:opts)
  def name
    "Access app"
  end

  def ping!
    return unless configured?
    return unless opts[:message].present?
    client.ping opts[:message]
  end

  def client
    @client ||= Slack::Notifier.new AppConfig.slack.webhook_url,
                               channel: ["#", AppConfig.slack.default_channel].join,
                               username: name
  end

  def configured?
    AppConfig.slack? and AppConfig.slack.webhook_url?
  end
end
