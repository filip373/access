require 'slack-notifier'
  def notify_on_change
    client.ping message
  end

  def message
    "Click here: #{compare_url} to review.\nClick here: #{app_url} to apply."
  end

class SlackNotification < Struct.new(:opts)
  def name
    "Access app"
  end

  def ping!
    return unless opts[:message].present?
    client.ping opts[:message]
  end

  def client
    @client ||= Slack::Notifier.new AppConfig.slack.webhook_url,
                               channel: ["#", AppConfig.slack.default_channel].join,
                               username: name
  end
end
