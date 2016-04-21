#
# FFmpeg Abstraction
#

require 'command'
require 'capturer'

module VCSRuby
  class FFmpeg < Capturer
    def initialize video
      @video = video
      @command = Command.new :ffmpeg, 'ffmpeg'
    end

    def length
      info = @command.execute("-i #{@video} -dframes 0 -vframes 0 /dev/null", "2>&1")
      match = /Duration: ([\d|:|.]*)/.match(info)
      return TimeIndex.new match[1]
    end
  end
end
