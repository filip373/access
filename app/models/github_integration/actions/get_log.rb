module Log
  class Github < Base

    create_model({ model: :team,
      models: :teams,
      mod_prop: :name,
      items: [:members, :repos],
      new_model_items: [:members, :repos, :permissions] })

    def initialize(diff)
      super
    end

    def now!
      generate_log(:teams, [:members, :repos])
    end

    private

    def generate_log(teams, items)
      super
      log_changing_permissions
      @log << "There are no changes." if @log.size == 0
      @log
    end

    def log_changing_permissions
      @diff[:change_permissions].each do |team, permissions|
        @log << "[api] change permission #{team.name} - #{permissions}"
      end
    end

  end
end
