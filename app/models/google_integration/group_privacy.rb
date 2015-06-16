module GoogleIntegration
  class GroupPrivacy
    pattr_initialize :options
    delegate :who_can_view_group, :show_in_group_directory?, to: :options

    OPEN_VIEW_POLICY = 'ALL_IN_DOMAIN_CAN_VIEW'.freeze
    CLOSED_VIEW_POLICY = 'ALL_MEMBERS_CAN_VIEW'.freeze

    def open?
      who_can_view_group == OPEN_VIEW_POLICY && show_in_group_directory?
    end

    def closed?
      who_can_view_group == CLOSED_VIEW_POLICY && !show_in_group_directory?
    end

    def to_s
      return 'open' if open?
      return 'closed' if closed?
      raise NotImplementedError, 'we have no idea what privacy is this?'
    end

    def open!
      @options.who_can_view_group = OPEN_VIEW_POLICY
      @options.show_in_group_directory = true
      self
    end

    def close!
      @options.who_can_view_group = CLOSED_VIEW_POLICY
      @options.show_in_group_directory = false
      self
    end

    def to_google_params
      {
        whoCanViewGroup: who_can_view_group,
        showInGroupDirectory: show_in_group_directory?.to_s,
      }
    end
  end
end
