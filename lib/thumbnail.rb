#
# Thumbnails from video
#

module VCSRuby
  class Thumbnail
    attr_accessor :width, :height, :aspect

    def capture
      raise "NotImplementedException"
    end
  end
end
