class HipchatNotifier < Struct.new(:token, :room, :compare_url, :app_url)
  def notify_on_change
    client[room].send(name, message, notify: true, message_format: :text, color: 'purple')
  end

  def message
    "Click here: #{compare_url} to review.\nClick here: #{app_url} to apply."
  end

  def name
    "Github Access"
  end

  def client
    @client ||= HipChat::Client.new(token)
  end
end
