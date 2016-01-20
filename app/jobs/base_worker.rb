class BaseWorker < ActiveJob::Base
  protected

  def data_guru
    @data_guru ||= DataGuru::Client.new
  end

  def user_repo
    @user_repo ||= UserRepository.new(data_guru.members.all)
  end

  def api
    raise NotImplementedError
  end

  def api_teams
    raise NotImplementedError
  end

  def expected_teams
    raise NotImplementedError
  end
end
