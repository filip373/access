module JiraIntegration
  module Constants
    JIRA_ROLES = ['Developers', 'PM Team', 'QA Team', 'Client Dev', 'Clients'].freeze
    DATAGURU_ROLES = [:developers, :pms, :qas, :client_developers, :clients].freeze
    ROLES_MAPPING = Hash[JIRA_ROLES.zip(DATAGURU_ROLES)].freeze
    INVERTED_ROLES_MAPPING = ROLES_MAPPING.invert.freeze
  end
end
