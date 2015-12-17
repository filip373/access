if Rails.env.development?
  HttpLog.options[:compact_log] = true
end
