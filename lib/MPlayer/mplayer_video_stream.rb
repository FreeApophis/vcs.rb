#
# Implementes VideoStream Interface for MPlayer
#

# VideoStream = Struct.new(:width, :height, :codec, :color_space, :bit_rate, :frame_rate, :aspect_ratio, :raw)

module VCSRuby
  class MPlayerVideoStream
    attr_reader :raw

    def initialize video_stream
      @raw = video_stream
    end

    def width
      @raw['ID_VIDEO_WIDTH'].to_i
    end

    def height
      @raw['ID_VIDEO_HEIGHT'].to_i
    end

    def codec short = false
      @raw['ID_VIDEO_FORMAT']
    end

    def color_space
      ''
    end

    def bit_rate
      @raw['ID_VIDEO_BITRATE'].to_i
    end


    def frame_rate
      @raw['ID_VIDEO_FPS'].to_f
    end

    def aspect_ratio
      ''
    end
  end
end
