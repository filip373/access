module GoogleIntegration
  module Actions
    class Log
      attr_reader :log, :errors

      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
        @errors = log_errors
      end

      def now!
        generate_log
      end

      # rubocop:disable Metrics/MethodLength
      def generate_log
        log_creating_groups
        log_adding_members
        log_removing_members
        log_adding_aliases
        log_removing_aliases
        log_adding_memberships
        log_removing_memberships
        log_changing_archive
        log_changing_privacy
        log_adding_user_aliases
        log_removing_user_aliases
        no_changes_in_log
      end
      # rubocop:enable Metrics/MethodLength

      private

      def no_changes_in_log
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_errors
        Hash(@diff_hash[:errors]).map do |key, errors|
          "[#{key} error] #{errors}"
        end
      end

      def log_changing_privacy
        @diff_hash[:change_privacy].each do |group, privacy|
          @log << "[api] change group #{group.email} privacy settings to #{privacy}"
        end if @diff_hash[:change_privacy].present?
      end

      def log_changing_archive
        @diff_hash[:change_archive].each do |group, flag|
          @log << "[api] change group #{group.email} archive settings to #{flag}"
        end if @diff_hash[:change_archive].present?
      end

      def log_creating_groups
        @diff_hash[:create_groups].each do |group, h|
          @log << "[api] create group #{group.email}"
          add_members_message(h, group)
          add_aliases_message(h, group)
          add_membership_message(h, group)
        end if @diff_hash[:create_groups].present?
      end

      def add_membership_message(h, group)
        return if h[:add_membership].nil?
        @log << "[api] add domain membership to group #{group.email}"
      end

      def add_members_message(h, group)
        h[:add_members].each do |m|
          @log << "[api] add member #{m} to group #{group.email}"
        end if h[:add_members]
      end

      def add_aliases_message(h, group)
        h[:add_aliases].each do |r|
          @log << "[api] add alias #{r} to group #{group.email}"
        end if h[:add_aliases]
      end

      def log_adding_memberships
        @diff_hash[:add_membership].each do |group, _membership|
          @log << "[api] add domain membership to group #{group.email}"
        end if @diff_hash[:add_membership]
      end

      def log_adding_members
        @diff_hash[:add_members].each do |group, members|
          members.each do |m|
            @log << "[api] add member #{m} to group #{group.email}"
          end
        end if @diff_hash[:add_members]
      end

      def log_removing_memberships
        @diff_hash[:remove_membership].each do |group, _membership|
          @log << "[api] remove domain membership from group #{group.email}"
        end if @diff_hash[:remove_membership]
      end

      def log_removing_members
        @diff_hash[:remove_members].each do |group, members|
          members.each do |m|
            @log << "[api] remove member #{m} from group #{group.email}"
          end
        end if @diff_hash[:remove_members]
      end

      def log_adding_aliases
        @diff_hash[:add_aliases].each do |group, aliases|
          aliases.each do |a|
            @log << "[api] add alias #{a} to group #{group.email}"
          end
        end if @diff_hash[:add_aliases]
      end

      def log_removing_aliases
        @diff_hash[:remove_aliases].each do |group, aliases|
          aliases.each do |a|
            @log << "[api] remove alias #{a} from group #{group.email}"
          end
        end if @diff_hash[:remove_aliases]
      end

      def log_adding_user_aliases
        @diff_hash[:add_user_aliases].each do |user, aliases|
          aliases.each do |a|
            @log << "[api] add user alias #{a} to user #{user.id}"
          end
        end if @diff_hash[:add_user_aliases]
      end

      def log_removing_user_aliases
        @diff_hash[:remove_user_aliases].each do |user, aliases|
          aliases.each do |a|
            @log << "[api] remove user alias #{a} from user #{user.id}"
          end
        end if @diff_hash[:remove_user_aliases]
      end
    end
  end
end
