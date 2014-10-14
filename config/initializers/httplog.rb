HttpLog.options[:logger]        = Logger.new($stdout)
HttpLog.options[:severity]      = Logger::Severity::DEBUG
HttpLog.options[:log_connect]   = false
HttpLog.options[:log_request]   = true
HttpLog.options[:log_headers]   = false
HttpLog.options[:log_data]      = false
HttpLog.options[:log_status]    = true
HttpLog.options[:log_response]  = false
HttpLog.options[:log_benchmark] = false

HttpLog.options[:logger] = Rails.logger
