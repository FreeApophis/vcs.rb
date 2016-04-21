#
# FFmpeg Abstraction
#

require 'capturer'
require 'command'
require 'time_index'

module VCSRuby
  class LibAV < Capturer
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
      info = @avprobe.execute("#{@video}", "2>&1")
      match = /Duration: ([\d|:|.]*)/.match(info)
      return TimeIndex.new match[1]
    end

    def to_s
      "LibAV #{@version}"
    end
  end
end
