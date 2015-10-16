module GithubIntegration
  class TeamLog
    pattr_initialize :team_name, :changes { @log = [] }
    attr_reader :log

    def now!
      log_team
      log
    end

    private

    def log_team(changes)
      log_adding(changes[:add])
      log_removing(changes[:remove])
    end

    def log_adding(changes)
      log_adding_members(changes[:members])
      log_adding_repos(changes[:repos])
      log_changing_permissions(changes[:permission])
    end

    def log_removing(changes)
      log_removing_members(changes[:members])
      log_removing_repos(changes[:repos])
    end

    def log_changing_permissions(permission)
      log << "[gh] change permissions #{team_name} - #{permission}"
    end

    def log_adding_members(members)
      members.each { |m| log << "[gh] add member #{m} to team #{team_name}" }
    end

    def log_removing_members(members)
      members.each { |m| log << "[gh] remove member #{m} from team #{team_name}" }
    end

    def log_adding_repos(repos)
      repos.each { |r| log << "[gh] add repo #{r} to team #{team_name}" }
    end

    def log_removing_repos(repos)
      repos.each { |r| log << "[gh] remove repo #{r} from team #{team_name}" }
    end
  end
end
