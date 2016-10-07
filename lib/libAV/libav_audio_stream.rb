#
# Implementes AudioStream Interface for libAV
#

# AudioStream = Struct.new(:codec, :channels, :channel_layout, :sample_rate, :bit_rate, :raw)
module VCSRuby
  class LibAVAudioStream
    attr_reader :raw

    def initialize audio_stream
      @raw = audio_stream
    end

    def codec short = false
      if short
        @raw['codec_name']
      else
        @raw['codec_long_name']
      end
    end

    def channels
      @raw['channels'].to_i
    end

    def channel_layout
      @raw['channel_layout']
    end

    def sample_rate
      @raw['sample_rate'].to_i
    end

    def bit_rate
      @raw['bit_rate'].to_i
    end
  end
end