module GoogleIntegration
  module Helpers
    class User
      def self.email_to_username(email)
        email.try(:sub, domains_regexp, '')
      end

      def self.any_email_to_username(email)
        email.try(:split, '@').try(:first)
      end

      def self.username_to_email(username)
        "#{username}@#{main_domain}"
      end

      def self.domains_regexp # /@(one_domain.co$|anotherdomain.co$)/
        /@(#{main_domain}$|#{other_domains.join("$|")}$)/
      end

      def self.main_domain
        AppConfig.google.main_domain
      end

      def self.other_domains
        AppConfig.google.other_domains
      end
    end
  end
end
