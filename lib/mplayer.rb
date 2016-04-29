#
# MPlayer Abstraction
#

require 'command'
require 'capturer'

module VCSRuby
  class MPlayer < Capturer
    def initialize video
      @video = video
      @mplayer = Command.new :mplayer, 'mplayer'
    end

    def name
      :mplayer
    end

    def available?
      @mplayer.available?
    end
  end
end
