#
# Implementes AudioStream Interface for FFmmpeg
#

# AudioStream = Struct.new(:codec, :channels, :sample_rate, :bit_rate, :raw)
module VCSRuby
  class FFmpegAudioStream
    attr_reader :raw

    def initialize audio_stream
      @raw = audio_stream
    end

    def codec
      @raw['codec_long_name']
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