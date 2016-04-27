#
# Thumbnails from video
#

require 'mini_magick'

module VCSRuby
  class Thumbnail
    attr_accessor :width, :height, :aspect
    attr_accessor :image_path
    attr_accessor :time

    def initialize capper, video, configuration
      @capper = capper
      @video = video
      @configuration = configuration

      @filters = [method(:resize_filter), method(:timestamp_filter)]
    end

    def capture 
      @capper.grab @time, @image_path
    end

    def blank?
      image = MiniMagick::Image.open @image_path
      image.colorspace 'Gray'
      mean = image['%[fx:image.mean]'].to_f
      return mean < @configuration.blank_threshold
    end

    def apply_filters
      MiniMagick::Tool::Convert.new do |convert|
        convert.background 'Transparent'
        convert.fill 'Transparent'
        convert << @image_path
        @filters.each do |filter|
          filter.call(convert)
        end
        convert << @image_path
      end
    end

private
    def resize_filter convert
      convert.resize "#{width}x#{height}!"
    end

    def timestamp_filter convert
      convert.stack do |box|
        box.box @configuration.timestamp_background
        box.fill  @configuration.timestamp_color
        box.stroke 'None'
        box.pointsize @configuration.timestamp_font.size
        box.gravity 'SouthEast'
        box.font @configuration.timestamp_font.path
        box.strokewidth 3
        box.annotate('+5+5', @time.to_timestamp)
      end
      convert.flatten
      convert.gravity 'None'
    end

    def photoframe_filter convert
      convert.bordercolor 'White'
      convert.border 3
      convert.bordercolor 'Grey60'
      convert.border 1
    end

    def softshadow_filter convert
      convert.stack do |box|
        box.background 'Black'
        box.clone.+
        box.shadow '50x2+4+4'
        box.background 'None'
      end
      convert.swap.+
      convert.flatten
      convert.trim
      convert.repage
    end

    def polaroid_filter
    end

    def random_rotation_filter
    end

    def film_filter
    end
  end
end
