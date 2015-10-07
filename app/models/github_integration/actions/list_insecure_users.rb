module GithubIntegration
  module Actions
    class ListInsecureUsers
      attr_accessor :gh_members, :users, :github_teams

      def initialize(gh_members, users, github_teams)
        self.gh_members = gh_members
        self.users = users
        self.github_teams = github_teams
      end

      def call
        convert_members_to_users.sort_by { |u| u.name.to_s.downcase }
      end

      private

      def convert_members_to_users
        gh_members.map do |m|
          dg_user = users.find do |u|
            u.github.to_s.downcase == m['login'].downcase
          end
          teams = github_teams.select { |t| t.members.map(&:downcase).any? { |m| m.match(dg_user.id.downcase) } }
          u = InsecureUser.new(github: dg_user.id,
                               name: dg_user.name,
                               emails: dg_user.emails,
                              )
          u.html_url = m['html_url']
          u.github_teams = teams.map(&:id).join(', ')
          u
        end
      end
    end
    class InsecureUser < User
      attr_accessor :html_url, :github_teams
    end
  end
end
