module GithubIntegration
  module Actions
    class ListInsecureUsers
      attr_accessor :gh_members

      def initialize(gh_members)
        self.gh_members = gh_members
      end

      def call
        convert_members_to_users.sort_by { |u| u.name.to_s.downcase }
      end

      private

      def convert_members_to_users
        gh_members.map do |m|
          user = User.find_user_by_github(m['login'])
          user.html_url = m['html_url']
          user
        end
      end
    end
  end
end
