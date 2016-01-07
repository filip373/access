class TodaysLogs
  def self.call(date: Time.zone.today)
    File.open(Rails.root.join('log/audit.log'), 'r') do |f|
      f.grep(/#{date.strftime('%Y-%m-%d')}/)
    end
  rescue
    []
  end
end
