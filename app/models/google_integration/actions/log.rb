module GoogleIntegration
  module Actions
    class Log < BaseActions::Log::Base

      create_model({ model: :group,
        models: :groups,
        mod_prop: :email,
        items: [:members, :aliases],
        new_model_items: [:members, :aliases] })

      def initialize(diff)
        super
      end

      def now!
        # TODO: it should be possible to share opts between methods inside the child class,
        # this way we could write #now! inside the base class and be done with id.
        generate_log(:groups, [:members, :aliases])
      end

      private

      def generate_log(groups, items)
        super
        @log << "There are no changes." if @log.size == 0
        @log
      end
    end
  end
end
