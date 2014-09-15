class GithubController < ApplicationController
  expose(:gh_api){  GhApi.new(session[:token], AppConfig.company)  }

  expose(:expected_teams){ ExpectedTeams.new.all }

  expose(:sync){ Actions::SyncTeams.new(expected_teams, gh_api) }

	def do_sync
    sync.now!

  	render
	end

  def index
  end
end
