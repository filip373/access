require_relative '../../app/models/slack_notification'
task :notify do
  notifier = SlackNotication.new(ENV['SLACK_TOKEN'], ENV['SLACK_ROOM'], ENV['CIRCLE_COMPARE_URL'], ENV['APP_URL'])
  notifier.notify_on_change
end
