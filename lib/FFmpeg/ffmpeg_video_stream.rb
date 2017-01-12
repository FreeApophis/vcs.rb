#
# Implementes VideoStream Interface for FFmpeg
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

    def codec short = false
      if short
        @raw['codec_name']
      else
        @raw['codec_long_name']
      end
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
      if @raw['r_frame_rate']
        @raw['r_frame_rate'].to_r
      elsif @raw['avg_frame_rate']
        @raw['avg_frame_rate'].to_r
      end
    end

    def aspect_ratio
      colon = ":"
      if @raw['display_aspect_ratio'].include? colon
        w,h = @raw['display_aspect_ratio'].split(colon)
        Rational(w,h)
      else
        @raw['display_aspect_ratio'].to_f
      end
    end
  end
end
