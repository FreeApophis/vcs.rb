#
# FFmpeg Abstraction
#

require 'capturer'
require 'command'
require 'time_index'

module VCSRuby
  class LibAV < Capturer

    CODEC = 2
    DIMENSION = 4
    FPS = 6

    def initialize video
      @video = video
      @avconv = Command.new :libav, 'avconv'
      @avprobe = Command.new :libav, 'avprobe'
      detect_version
    end

    def name
      :libav
    end

    def available?
      @avconv.available? && @avprobe.available?
    end

    def detect_version
      info = @avconv.execute('-version')
      match = /avconv ([\d|.|-|:]*)/.match(info)
      @version = match[1] if match
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

    def fps
      load_probe
      @fps
    end

    def video_codec
      load_probe

      @video_codec
    end

    def audio_codec
      load_probe

      @audio_codec
    end

    def grab time, image_path
      @avconv.execute "-y -ss #{time.total_seconds} -i \"#{@video}\" -an -dframes 1 -vframes 1 -vcodec png -f rawvideo \"#{image_path}\""
    end

    def to_s
      "LibAV #{@version}"
    end

private
    def load_probe
      return if @cache

      @cache = @avprobe.execute("\"#{@video}\"", "2>&1")
      puts @cache if Tools.verbose?

      parse_video_streams
      parse_audio_streams
    end

    def parse_video_streams
      video_stream = split_stream_line(is_stream?(@cache, /Video/).first)

      dimensions = /(\d*)x(\d*) \[PAR (\d*:\d*) DAR (\d*:\d*)\]/.match(video_stream[DIMENSION])

      if dimensions
        @par = dimensions[3]
        @dar = dimensions[4]
      else
        dimensions = /(\d*)x(\d*)/.match(video_stream[DIMENSION])
      end

      if dimensions
        @width = dimensions[1].to_i
        @height = dimensions[2].to_i
      end

      fps = /([\d|.]+) fps/.match(video_stream[FPS])
      @fps = fps ? fps[1].to_f : 0.0

      @video_codec = video_stream[CODEC]
    end

    def parse_audio_streams
      audio_stream = split_stream_line(is_stream?(@cache, /Audio/).first)

      @audio_codec = audio_stream[CODEC]
    end

    def is_stream? probe, regex
      streams(probe).select{ |s| s =~ regex }
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
