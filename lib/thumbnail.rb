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
      @blank_threshold = 0.10
    end

    def capture 
      @capper.grab @time, @image_path

      image = MiniMagick::Image.open @image_path
      image.resize "#{width}x#{height}!"
      image.write @image_path
    end

    def blank?
      image = MiniMagick::Image.open @image_path
      image.colorspace 'Gray'
      mean = image['%[fx:image.mean]'].to_f
      return mean < @blank_threshold
    end
  end
end
