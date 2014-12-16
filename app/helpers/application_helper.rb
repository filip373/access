module ApplicationHelper
  def log_empty? log
    log.first =~ /no changes/
  end
end
