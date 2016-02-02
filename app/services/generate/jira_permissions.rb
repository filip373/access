module Generate
  class JiraPermissions
    pattr_initialize :jira_api, :permissions_dir

    def call
      recreate_dir
      jira_api.projects.each do |project|
        create_project(project)
      end
    end

    private

    def dir
      permissions_dir.join 'jira_projects'
    end

    def recreate_dir
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)
    end

    def create_project(project)
      File.write(project_path(project.name), build_project(project).stringify_keys.to_yaml)
    end

    def project_path(name)
      dir.join(name.parameterize('_') + '.yml')
    end

    def build_project(project)
      {
        name: project.name,
        key: project.key,
      }.merge(JiraIntegration::Factories::JiraProjects.call(jira_api, Array(project))[project.key])
    end
  end
end
