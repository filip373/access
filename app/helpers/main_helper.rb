module MainHelper
  def logs_empty?
    @gh_log[0] =~ /no changes/ && @google_log[0] =~ /no changes/
  end
end
