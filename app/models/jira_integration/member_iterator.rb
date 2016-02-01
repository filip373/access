module JiraIntegration
  InvalidProjectsObject = Class.new(StandardError)

  class MemberIterator
    include Enumerable

    def initialize(projects)
      @projects = projects
    end

    def each(&block)
      projects.each do |key, roles|
        roles.each do |role, members|
          members.each { |member| block.call(key, role, member) }
        end
      end
    rescue StandardError => e
      fail InvalidProjectsObject
    end

    private

    attr_accessor :projects
  end
end
