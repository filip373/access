module GithubIntegration
  module Actions
    class ListInsecureUsers
      attr_accessor :gh_members, :users

      def initialize(gh_members, users)
        self.gh_members = gh_members
        self.users = users
      end

      def call
        convert_members_to_users.sort_by { |u| u.name.to_s.downcase }
      end

      private

      def convert_members_to_users
        gh_members.map do |m|
          dg_user = users.find do |u|
            u.github == m['login']
          end
           User.new(github: dg_user.id,
            name: dg_user.name,
            email: dg_user.email,
            html_url: m['html_url'])
        end
      end
    end
  end
end
