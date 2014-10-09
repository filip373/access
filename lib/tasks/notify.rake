require_relative '../../app/entities/slack_notification'
task :notify do
  notifier = SlackNotication.new(ENV['HIPCHAT_TOKEN'], ENV['HIPCHAT_ROOM'], ENV['CIRCLE_COMPARE_URL'], ENV['APP_URL'])
  notifier.notify_on_change
end
