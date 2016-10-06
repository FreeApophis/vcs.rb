#
# Frame from video
#

require 'mini_magick'

module VCSRuby
  class Frame
    attr_accessor :width, :height, :aspect
    attr_accessor :image_path
    attr_reader :filters, :time

    def initialize video, capturer, time
      @video = video
      @capturer = capturer
      @time = time
      @filters = []
    end

    def capture
      @capturer.grab @time, @image_path
    end

    def capture_and_evade interval = @video.info.duration
      times = [TimeIndex.new] + Configuration.instance.blank_alternatives
      times.select! { |t| (t < interval / 2) and (t > interval / -2) }
      times.map! { |t| @time + t }

      times.each do |time|
        @time = time
        capture
        break unless blank?
        puts "Blank frame detected. => #{@time}" unless Configuration.instance.quiet?
        puts "Giving up!" if time == times.last && !Configuration.instance.quiet?
      end
    end

    def blank?
      image = MiniMagick::Image.open @image_path
      image.colorspace 'Gray'
      mean = image['%[fx:image.mean]'].to_f
      return mean < Configuration.instance.blank_threshold
    end

    def apply_filters
      MiniMagick::Tool::Convert.new do |convert|
        convert.background 'Transparent'
        convert.fill 'Transparent'
        convert << @image_path

        sorted_filters.each do |filter|
          call_filter filter, convert
        end

        convert << @image_path
      end
    end

private
    def call_filter filter, convert
      if respond_to?(filter, true)
        method(filter).call(convert)
      else
        raise "Filter '#{filter}' does not exist"
      end
    end

    def sorted_filters
      [:resize_filter, :timestamp_filter, :photoframe_filter, :polaroid_filter, :random_rotation_filter, :softshadow_filter].select{ |filter| @filters.include?(filter) }
    end

    def resize_filter convert
      convert.resize "#{width}x#{height}!"
    end

    def timestamp_filter convert
      convert.stack do |box|
        box.box Configuration.instance.timestamp_background
        box.fill Configuration.instance.timestamp_color
        box.pointsize Configuration.instance.timestamp_font.size
        box.gravity 'SouthEast'
        if Configuration.instance.timestamp_font.exists?
          box.font Configuration.instance.timestamp_font.path
        end
        box.annotate('+10+10', " #{@time.to_timestamp} ")
      end
      convert.flatten
      convert.gravity 'None'
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

    def photoframe_filter convert
      convert.bordercolor 'White'
      convert.border 3
      convert.bordercolor 'Grey60'
      convert.border 1
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
      end
      convert.repage.+
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
