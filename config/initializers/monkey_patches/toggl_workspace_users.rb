module TogglV8
  class API
    # Gem doesn't provide it.
    def workspace_users(workspace_id)
      get "workspaces/#{workspace_id}/workspace_users"
    end
  end
end
