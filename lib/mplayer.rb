#
# MPlayer Abstraction
#

require 'command'
require 'capturer'

module VCSRuby
  class MPlayer < Capturer
    def initialize video
      @video = video
      @command = Command.new :mplayer, 'mplayer'
    end
  end
end
