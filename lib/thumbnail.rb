#
# Thumbnails from video
#

require 'mini_magick'

module VCSRuby
  class Thumbnail
    attr_accessor :width, :height, :aspect
    attr_accessor :time
    attr_accessor :image_path

    def initialize capper, video
      @capper = capper
      @video = video
    end

    def capture 
      @capper.grab @time, @image_path
      image = MiniMagick::Image.open(@image_path)
      image.resize "#{width}x#{height}!"
      image.write @image_path
    end
  end
end
