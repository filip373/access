class JiraFacade
  attr_reader_initialize :dataguru, :diff
  delegate :empty?, to: :log, prefix: true

  def log
    @log ||= JiraIntegration::Actions::Log.call(diff)
  end

  def missing_projects
    diff[:missing_projects]
  end

  def zombie_projects
    diff[:zombie_projects]
  end

  def validation_errors
    dataguru.errors
  end
end
