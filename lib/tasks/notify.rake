require_relative '../../app/models/slack_notification'
task :notify do
  notifier.notify_on_change
  notifier = SlackNotification.new(message: message)
end
