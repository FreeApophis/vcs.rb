#
# Implementes MetaInfo Interface for MPlayer
#

# MetaInformation = Struct.new(:duration, :bit_rate, :size, :format, :extension, :raw)

require_relative '../time_index'

module VCSRuby
  class MPlayerMetaInfo
    attr_reader :raw

    def initialize meta_info, filesize
      @raw = meta_info
      @filesize = filesize
    end

    def duration
      TimeIndex.new(@raw['ID_LENGTH'].to_f)
    end

    def bit_rate
      @raw['ID_AUDIO_BITRATE'].to_i + @raw['ID_VIDEO_BITRATE'].to_i
    end

    def size
      @filesize
    end

    def format
      extension
    end

    def extension
      ext = File.extname(@raw['ID_FILENAME'])
      ext[0] = ''
      ext
    end
  end
end