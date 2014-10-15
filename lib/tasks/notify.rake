require_relative '../../app/models/slack_notification'
task :notify do
  notifier = SlackNotication.new(ENV['SLACK_TOKEN'], ENV['SLACK_CHANNEL'], ENV['REVIEW_PATH'], ENV['APP_URL'])
  notifier.notify_on_change
end
