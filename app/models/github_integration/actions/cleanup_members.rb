module GithubIntegration
  module Actions
    class CleanupMembers
      attr_accessor :stranded_users, :gh_api, :company_name

      def initialize(stranded_users, gh_api, company_name)
        self.stranded_users = stranded_users
        self.gh_api = gh_api
        self.company_name = company_name
      end

      def now!
        stranded_users.map(&:github).each do |user|
          gh_api.remove_member_from_org(user, company_name)
        end
      end
    end
  end
end
