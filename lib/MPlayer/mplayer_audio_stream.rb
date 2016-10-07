#
# Implementes AudioStream Interface for MPlayer
#

# AudioStream = Struct.new(:codec, :channels, :channel_layout, :sample_rate, :bit_rate, :raw)
module VCSRuby
  class MPlayerAudioStream
    attr_reader :raw

    def initialize audio_stream
    end

    def codec short = false
    end

    def channels
    end

    def channel_layout
    end

    def sample_rate
    end

    def bit_rate
    end
  end
end