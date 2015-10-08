module TogglIntegration
  module MainHelper
    def toggl_project_path(workspace_id, project_id)
      "https://www.toggl.com/app/projects/#{workspace_id}/edit/#{project_id}"
    end
  end
end
