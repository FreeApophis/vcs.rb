#
# Implementes MetaInfo Interface for FFmmpeg
#

# MetaInformation = Struct.new(:duration, :bit_rate, :size, :format, :extension, :raw)

require_relative '../time_index'

module VCSRuby
  class FFmpegMetaInfo
    attr_reader :raw

    def initialize meta_info
      @raw = meta_info
    end

    def duration
      TimeIndex.new(@raw['duration'].to_f)
    end

    def bit_rate
      @raw['bit_rate'].to_i
    end

    def size
      @raw['size'].to_i
    end

    def format
      @raw['format_long_name']
    end

    def extension
      @raw['format_name']
    end
  end
end