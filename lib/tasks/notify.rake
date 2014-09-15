task notify: :environment do
  notifier = HipchatNotifier.new(ENV['HIPCHAT_TOKEN'], ENV['HIPCHAT_ROOM'], ENV['CIRCLE_COMPARE_URL'], ENV['APP_URL'])
  notifier.notify_on_change
end
