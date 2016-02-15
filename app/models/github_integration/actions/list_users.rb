module GithubIntegration
  module Actions
    class ListUsers
      attr_accessor :github_users, :dg_users, :gh_teams, :category

      def initialize(github_users, dg_users, gh_teams, category)
        self.github_users = github_users
        self.dg_users = dg_users
        self.gh_teams = gh_teams
        self.category = category
      end

      def call
        return [] if github_users.empty?
        users = Hash.new
        users[category], users[:missing_from_dg] = convert_members_to_users.tap do |users|
          users.reject!{|u| !u.github_teams.empty?} if list_teamless_users?
        end.sort_by {|u| u.name.to_s.downcase }
          .partition{ |u| u.instance_of?(ListedUser) }
        users
      end

      private

      def convert_members_to_users
        github_users.map do |gh_member|
          dg_user = dg_users.find do |user|
            user.github.to_s.downcase == gh_member['login'].downcase
          end
          build_user(dg_user, gh_member)
        end
      end

      def build_user(dg_user, gh_member)
        if dg_user.nil?
          DataGuruNilUser.new(gh_member)
        else
          user = ListedUser.new(github: dg_user.github,
                                name: dg_user.name,
                                emails: dg_user.emails)
          user.html_url = gh_member['html_url']
          user.github_teams = select_teams_with_user(dg_user.id)
          user
        end
      end

      def select_teams_with_user(user_id)
        gh_teams.select do |t|
          t.members.map(&:downcase).any? { |m| m.match(user_id.downcase) }
        end.map(&:id).join(', ')
      end

      def list_teamless_users?
        category == :teamless
      end
    end
  end
end
