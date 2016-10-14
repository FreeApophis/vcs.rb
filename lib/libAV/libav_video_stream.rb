#
# Implementes VideoStream Interface for libAV
#

# VideoStream = Struct.new(:width, :height, :codec, :color_space, :bit_rate, :frame_rate, :aspect_ratio, :raw)

module VCSRuby
  class LibAVVideoStream
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
      @raw['display_aspect_ratio']
    end
  end
end
