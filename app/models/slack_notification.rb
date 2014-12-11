require 'slack-notifier'
class SlackNotification < Struct.new(:token, :channel, :compare_url, :app_url, :opts)
  def notify_on_change
    client.ping message
  end

  def message
    "Click here: #{compare_url} to review.\nClick here: #{app_url} to apply."
  end

  def name
    "Access app"
  end

  def ping!
    client.ping opts[:message]
  end

  def client
    @client ||= Slack::Notifier.new AppConfig.company, token,
                               channel: channel,
                               username: name
  end
end
