#
# Implementes VideoStream Interface for FFmmpeg
#

# VideoStream = Struct.new(:width, :height, :codec, :color_space, :bit_rate, :frame_rate, :aspect_ratio, :raw)

module VCSRuby
  class FFmpegVideoStream
    attr_reader :raw

    def initialize video_stream
      @raw = video_stream
    end

    def width
      @raw['width'].to_i
    end

    def height
      @raw['height'].to_i
    end

    def codec
      @raw['codec_long_name']
    end

    def color_space
      if ["unknown", "", nil].include? @raw['color_space']
        @raw['pix_fmt']
      else
        @raw['color_space']
      end
    end

    def bit_rate
      @raw['bit_rate'].to_i
    end


    def frame_rate
      Rational(@raw['r_frame_rate'])
    end

    def aspect_ratio
      @raw['display_aspect_ratio']
    end
  end
end
