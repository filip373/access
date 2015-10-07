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
        gh_members.map do |gh_member|
          dg_user = users.find do |u|
            u.github.to_s.downcase == gh_member['login'].downcase
          end
          build_user(dg_user, gh_member)
        end
      end

      def build_user(dg_user, gh_member)
        u = InsecureUser.new(github: dg_user.id,
                             name: dg_user.name,
                             emails: dg_user.emails,
                            )
        u.html_url = gh_member['html_url']
        u.github_teams = select_teams_with_user(dg_user.id)
        u
      end

      def select_teams_with_user(user_id)
        github_teams.select do |t|
          t.members.map(&:downcase).any? { |m| m.match(user_id.downcase) }
        end.map(&:id).join(', ')
      end
    end

    class InsecureUser < User
      attr_accessor :html_url, :github_teams
    end
  end
end
