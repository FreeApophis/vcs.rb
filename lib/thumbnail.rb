#
# Thumbnails from video
#

module VCSRuby
  class Thumbnail
    attr_accessor :width, :height, :aspect
    attr_accessor :time

    def initialize capper, video
      @capper = capper
      @video = video
    end

    def capture 
      @capper.grab @time
    end
  end
end
