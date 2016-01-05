class TodaysLogs
  def self.call(date: Date.today)
    File.open(Rails.root.join('log/audit.log'), 'r') do |f|
      f.grep(/#{date.to_s}/)
    end
  end
end
