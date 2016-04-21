#
# FFmpeg Abstraction
#

require 'capturer'
require 'command'
require 'time_index'

module VCSRuby
  class LibAV < Capturer
    DIMENSION = 4
    def initialize video
      @video = video
      @avconv = Command.new :libav, 'avconv'
      @avprobe = Command.new :libav, 'avprobe'
      detect_version
    end

    def available?
      @avconv.available && @avprobe.available
    end

    def detect_version
      info = @avconv.execute("-version")
      match = /avconv ([\d|.|-|:]*)/.match(info)
      @version = match[1]
    end

    def length
      load_probe
      match = /Duration: ([\d|:|.]*)/.match(@cache)
      return TimeIndex.new match[1]
    end

    def width
      load_probe
      @width
    end

    def height
      load_probe
      @height
    end

    def par
      load_probe
      @par
    end

    def dar
      load_probe
      @dar
    end

    def grab time, image_path
      @avconv.execute "-ss #{time.total_seconds} -i #{@video} -an -dframes 1 -vframes 1 -vcodec png -f rawvideo #{image_path}"
    end

    def to_s
      "LibAV #{@version}"
    end

private
    def load_probe
      return if @cache

      @cache = @avprobe.execute("#{@video}", "2>&1")

      parse_dimensions
    end

    def parse_dimensions
      video_stream = split_stream_line(video_streams(@cache).first)

      dimensions = /(\d*)x(\d*) \[PAR (\d*:\d*) DAR (\d*:\d*)\]/.match(video_stream[DIMENSION])

      @width = dimensions[1]
      @height = dimensions[2]
      @par = dimensions[3]
      @dar = dimensions[4]
    end

    def video_streams probe
      streams(probe).select{ |s| s =~ /Video/ }
    end

    def streams probe
      @cache.split(/\r?\n/).map(&:strip).select{|l| l.start_with? 'Stream' }
    end

    def split_stream_line line
      parts = line.split(',')
      stream = parts.shift
      result = stream.split(':')
      result += parts

      return result.map(&:strip)
    end
  end
end
