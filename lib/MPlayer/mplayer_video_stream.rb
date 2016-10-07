#
# Implementes VideoStream Interface for MPlayer
#

# VideoStream = Struct.new(:width, :height, :codec, :color_space, :bit_rate, :frame_rate, :aspect_ratio, :raw)

module VCSRuby
  class MPlayerVideoStream
    attr_reader :raw

    def initialize video_stream
    end

    def width
    end

    def height
    end

    def codec short = false
    end

    def color_space
    end

    def bit_rate
    end


    def frame_rate
    end

    def aspect_ratio
    end
  end
end
