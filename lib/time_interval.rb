#
# Time interval
#

module VCSRuby
  class TimeInterval
    attr_reader :total_seconds

    def initialize time_interval_string
      @total_sconds = 123
    end

    def seconds
      @total_seconds / 60
    end
    def hours
      (@total_seconds / 3600)
    end
    def minutes
      (@total_seconds / 60) % 60
    end
    def seconds
      @total_seconds % 60
    end
  end
end
