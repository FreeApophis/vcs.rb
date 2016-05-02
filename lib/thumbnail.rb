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
      @filters = [ method(:resize_filter),  method(:timestamp_filter), method(:softshadow_filter) ]
    end

    def capture
      @capper.grab @time, @image_path
    end

    def capture_and_evade interval
      times = [TimeIndex.new] + @configuration.blank_alternatives
      times.select! { |t| (t < interval / 2) and (t > interval / -2) }
      times.map! { |t| @time + t }

      times.each do |time|
        @time = time
        capture
        break unless blank?
        puts "Blank frame detected. => #{@time}" unless Tools::quiet?
        puts "Giving up!" if time == times.last && !Tools::quiet?
      end
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
        box.pointsize @configuration.timestamp_font.size
        box.gravity 'SouthEast'
        if @configuration.timestamp_font.exists?
          box.font @configuration.timestamp_font.path 
        end
        box.annotate('+10+10', " #{@time.to_timestamp} ")
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
      convert.repage.+
    end

    def polaroid_filter convert
      border = 8
      convert.stack do |a|
        a.fill 'White'
        a.background 'White'
        a.bordercolor 'White'
        a.mattecolor 'White'
        a.frame "#{border}x#{border}"
        a.stack do |b|
          b.flip
          b.splice "0x#{border*5}"
        end
        a.flip
        a.bordercolor 'Grey60'
        a.border 1
        a.repage.+
      end
    end

    def random_rotation_filter convert
      angle = Random::rand(-18..18)
      convert.background 'None'
      convert.rotate angle
    end

    def film_filter
    end
  end
end
