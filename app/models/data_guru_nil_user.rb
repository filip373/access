class DataGuruNilUser < ListedUser
  def initialize(gh_user)
    self.emails = []
    self.github = gh_user.fetch('login')
    self.github_teams = []
    self.html_url = gh_user.fetch('html_url')
    self.name = ''
  end
end
