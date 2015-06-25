module GoogleIntegration
  class GroupPrivacy
    pattr_initialize :who_can_view_group, :show_in_group_directory

    OPEN_VIEW_POLICY = 'ALL_IN_DOMAIN_CAN_VIEW'.freeze
    CLOSED_VIEW_POLICY = 'ALL_MEMBERS_CAN_VIEW'.freeze

    def self.from_google_api(group)
      return new('unknown', 'unknown') if group.try(:settings).nil?
      new(
        group.settings.whoCanViewGroup,
        group.settings.showInGroupDirectory,
      )
    end

    def self.from_string(privacy)
      instance = new(nil, nil)
      instance.open! if privacy == 'open'
      instance.close! if privacy == 'closed'
      instance
    end

    def open?
      who_can_view_group == OPEN_VIEW_POLICY && show_in_group_directory?
    end

    def closed?
      who_can_view_group == CLOSED_VIEW_POLICY && !show_in_group_directory?
    end

    def can_change?
      return true if default.present?
      [open?, closed?].any? { |privacy| privacy == true }
    end

    def !=(other)
      [open?, closed?] != [other.open?, other.closed?]
    end

    def ==(other)
      [open?, closed?] == [other.open?, other.closed?]
    end

    def to_s
      return 'open' if open?
      return 'closed' if closed?
      default || 'unknown'
    end

    def to_google_params
      {
        whoCanViewGroup: who_can_view_group,
        showInGroupDirectory: show_in_group_directory?.to_s,
      }
    end

    def open!
      @who_can_view_group = OPEN_VIEW_POLICY
      @show_in_group_directory = 'true'
      self
    end

    def close!
      @who_can_view_group = CLOSED_VIEW_POLICY
      @show_in_group_directory = 'false'
      self
    end

    def show_in_group_directory?
      return true if show_in_group_directory == 'true'
      return false if show_in_group_directory == 'false'
    end

    private

    def default
      GoogleIntegration::Defaults.group.try(:privacy)
    end
  end
end
