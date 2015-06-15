module GoogleIntegration
  module Actions
    class Log
      def initialize(diff_hash)
        @diff_hash = diff_hash
        @log = []
      end

      def now!
        generate_log
      end

      private

      def generate_log
        log_creating_groups
        log_adding_members
        log_removing_members
        log_adding_aliases
        log_removing_aliases
        log_adding_memberships
        log_removing_memberships
        log_changing_archive
        @log << 'There are no changes.' if @log.size == 0
        @log
      end

      def log_changing_archive
        @diff_hash[:change_archive].each do |group, flag|
          @log << "[api] change group #{group.email} archive settings to #{flag}"
        end
      end

      def log_creating_groups
        @diff_hash[:create_groups].each do |group, h|
          @log << "[api] create group #{group.email}"

          h[:add_members].each do |m|
            @log << "[api] add member #{m} to group #{group.email}"
          end if h[:add_members]

          h[:add_aliases].each do |r|
            @log << "[api] add alias #{r} to group #{group.email}"
          end if h[:add_aliases]

          unless h[:add_membership].nil?
            @log << "[api] add domain membership to group #{group.email}"
          end
        end
      end

      def log_adding_memberships
        @diff_hash[:add_membership].each do |group, membership|
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
        @diff_hash[:remove_membership].each do |group, membership|
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
    end
  end
end
