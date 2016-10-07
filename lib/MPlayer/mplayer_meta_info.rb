#
# Implementes MetaInfo Interface for MPlayer
#

# MetaInformation = Struct.new(:duration, :bit_rate, :size, :format, :extension, :raw)

require_relative '../time_index'

module VCSRuby
  class MPlayerMetaInfo
    attr_reader :raw

    def initialize meta_info
    end

    def duration
    end

    def bit_rate
    end

    def size
    end

    def format
    end

    def extension
    end
  end
end