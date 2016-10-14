#
# Implementes AudioStream Interface for MPlayer
#

# AudioStream = Struct.new(:codec, :channels, :channel_layout, :sample_rate, :bit_rate, :raw)
module VCSRuby
  class MPlayerAudioStream
    attr_reader :raw

    def initialize audio_stream
      @raw = audio_stream
    end

    def codec short = false
      @raw['ID_AUDIO_CODEC']
    end

    def channels
      @raw['ID_AUDIO_NCH'].to_i
    end

    def channel_layout
      ''
    end

    def sample_rate
      @raw['ID_AUDIO_RATE'].to_i
    end

    def bit_rate
      @raw['ID_AUDIO_BITRATE'].to_i
    end
  end
end