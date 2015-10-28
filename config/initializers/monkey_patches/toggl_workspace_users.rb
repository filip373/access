module TogglV8
  class API
    # Gem doesn't provide it.
    def workspace_users(workspace_id)
      get "workspaces/#{workspace_id}/workspace_users"
    end

    def update_workspace_user(workspace_user_id, params)
      put "workspace_users/#{workspace_user_id}", 'workspace_user' =>  params
    end

    def invite_member(workspace_id, email)
      post("workspaces/#{workspace_id}/invite", 'emails' =>  [email])[0]
    end
  end
end
