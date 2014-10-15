require 'slack-notifier'
class SlackNotication < Struct.new(:token, :channel, :compare_url, :app_url)
  def notify_on_change
    client.ping message
  end

  def message
    "Click here: #{compare_url} to review.\nClick here: #{app_url} to apply."
  end

  def name
    "Github Access"
  end

  def client
    @client ||= Slack::Notifier.new "netguru", token,
                               channel: channel,
                               username: 'permissions'
  end
end
