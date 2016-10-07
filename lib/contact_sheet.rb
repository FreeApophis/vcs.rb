#
# Contact Sheet Composited from the Thumbnails
#

require 'fileutils'
require 'tmpdir'
require 'yaml'

require 'vcs'

module VCSRuby
  class ContactSheet
    attr_accessor :format, :signature, :title, :highlight
    attr_accessor :softshadow, :timestamp, :polaroid
    attr_reader :thumbnail_width, :thumbnail_height
    attr_reader :length, :from, :to

    def initialize video, capturer
      @video = video
      @capturer = capturer
      @signature = "Created by Video Contact Sheet Ruby"
      initialize_filename

      if Configuration.instance.verbose?
        puts "Processing #{File.basename(video.full_path)}..."
      end

      return unless @video.valid?

      detect_video_properties

      @thumbnails = []
      @filters = []

      @from = TimeIndex.new 0
      @to = @video.info.duration

      @timestamp = Configuration.instance.timestamp
      @softshadow = Configuration.instance.softshadow
      @polaroid = Configuration.instance.polaroid

      @tempdir = Dir.mktmpdir

      ObjectSpace.define_finalizer(self, self.class.finalize(@tempdir) )
      initialize_geometry(Configuration.instance.rows, Configuration.instance.columns, Configuration.instance.interval)

    end

    def initialize_filename
      @out_path = File.dirname(@video.full_path)
      @out_filename = File.basename(@video.full_path,'.*')
    end

    def initialize_geometry(rows, columns, interval)
      @has_interval = !!interval
      @rows = rows
      @columns = columns
      @interval = interval
    end
    
    def filename
      "#{@out_filename}.#{@format ? @format.to_s : 'png'}"
    end

    def full_path
      File.join(@out_path, filename)
    end

    def rows
      @rows
    end

    def columns
      @columns
    end

    def interval
      @interval || (@to - @from) / (number_of_caps)
    end

    def number_of_caps
      if @has_interval
        (@to - @from) / @interval
      else
        if @rows && @columns
          @rows * @columns
        else
          raise "you need at least 2 parameters from columns, rows and interval"
        end
      end
    end

    def thumbnail_width= width
      @thumbnail_height = (width.to_f / @thumbnail_width * thumbnail_height).to_i
      @thumbnail_width = width
    end

    def thumbnail_height= height
      @thumbnail_width = (height.to_f / @thumbnail_height * thumbnail_width).to_i
      @thumbnail_height = height
    end

    def from= time
      if (TimeIndex.new(0) < time) && (time < to) && (time < @length)
        @from = time
      else
        raise "Invalid From Time"
      end
    end

    def to= time
      if (TimeIndex.new(0) < time) && (from < time) && (time < @length)
        @to = time
      else
        raise "Invalid To Time"
      end
    end

    def build
      if (@video.info.duration.total_seconds < 1.0)
        puts "Video is shorter than 1 sec"
      else
        @capturer.format = @capturer.available_formats.first
        initialize_filters
        initialize_thumbnails
        capture_thumbnails

        puts "Composing standard contact sheet..." unless Configuration.instance.quiet?
        montage = splice_montage(montage_thumbs)

        image = MiniMagick::Image.open(montage)

        puts "Adding header and footer..." unless Configuration.instance.quiet?
        final = add_header_and_footer image

        puts "Done. Output wrote to '#{filename}'" unless Configuration.instance.quiet?
        FileUtils.mv(final, full_path)
      end
    end

private
    def self.finalize(tempdir)
      proc do
        puts "Cleaning up..." unless Configuration.instance.quiet?
        FileUtils.rm_r tempdir
      end
    end

    def initialize_filters
      @filters << :resize_filter
      @filters << :softshadow_filter if softshadow
      @filters << :timestamp_filter if timestamp
      @filters << :polaroid_filter if polaroid
    end

    def initialize_thumbnails
      time = @from + (interval / 2)
      (1..number_of_caps).each do |i|
        thumb = Frame.new @video, @capturer, time
        time = time + interval
        thumb.width = thumbnail_width
        thumb.height = thumbnail_height
        thumb.image_path = File::join(@tempdir, "th#{"%03d" % i}.#{@capturer.format.to_s}")
        thumb.filters.push(*@filters)

        @thumbnails << thumb
      end
    end

    def capture_thumbnails
      puts "Capturing in range [#{from}..#{to}]. Total length: #{@length}" unless Configuration.instance.quiet?

      @thumbnails.each_with_index do |thumbnail, i|
        puts "Generating capture ##{i + 1}/#{number_of_caps} #{thumbnail.time}..." unless Configuration.instance.quiet?
        if Configuration.instance.blank_evasion?
          thumbnail.capture_and_evade interval
        else
          thumbnail.capture
        end
        thumbnail.apply_filters
      end
    end

    def detect_video_properties
      detect_length
      detect_dimensions
    end

    def detect_length
      @length = @video.info.duration

      @from = TimeIndex.new 0.0
      @to = @length
    end

    def detect_dimensions
      @thumbnail_width = @video.video.width
      @thumbnail_height = @video.video.height
    end

    def montage_thumbs
      file_path = File::join(@tempdir, 'montage.png')
      MiniMagick::Tool::Montage.new do |montage|
        montage.background Configuration.instance.contact_background
        @thumbnails.each do |thumbnail|
          montage << thumbnail.image_path
        end
        montage.geometry "+#{Configuration.instance.padding}+#{Configuration.instance.padding}"
        # rows or columns can be nil (auto fit)
        montage.tile "#{@columns}x#{@rows}"
        montage << file_path
      end
      return file_path
    end

    def splice_montage montage_path
      if softshadow
        left = Configuration.instance.padding + 3
        top = Configuration.instance.padding + 5
        bottom = right = Configuration.instance.padding
      else
        left = right = top = bottom = Configuration.instance.padding
      end


      file_path = File::join(@tempdir, 'spliced.png')
      MiniMagick::Tool::Convert.new do |convert|
        convert << montage_path
        convert.background Configuration.instance.contact_background

        convert.splice "#{left}x#{top}"
        convert.gravity 'SouthEast'
        convert.splice "#{right}x#{bottom}"

        convert << file_path
      end
      file_path
     end

    def create_title montage
      file_path = File::join(@tempdir, 'title.png')
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |ul|
          ul.size "#{montage.width}x#{Configuration.instance.title_font.line_height}"
          ul.xc Configuration.instance.title_background
          if Configuration.instance.title_font.exists?
            ul.font Configuration.instance.title_font.path
          end
          ul.pointsize Configuration.instance.title_font.size
          ul.background Configuration.instance.title_background
          ul.fill Configuration.instance.title_color
          ul.gravity 'Center'
          ul.annotate(0, @title)
        end
        convert.flatten
        convert << file_path
      end
      return file_path
    end

    def create_highlight montage
      puts "Generating highlight..."
      thumb = Frame.new @video, @highlight

      thumb.width = thumbnail_width
      thumb.height = thumbnail_height
      thumb.image_path = File::join(@tempdir, "highlight_thumb.png")
      thumb.capture
      thumb.apply_filters

      file_path =  File::join(@tempdir, "highlight.png")
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |a|
          a.size "#{montage.width}x#{thumbnail_height+20}"
          a.xc Configuration.instance.highlight_background
          a.gravity 'Center'
          a << thumb.image_path
          a.composite
        end
        convert.stack do |a|
          a.size "#{montage.width}x1"
          a.xc 'Black'
        end
        convert.append
        convert << file_path
      end

      file_path
    end

    def add_header_and_footer montage
      file_path = File::join(@tempdir, filename)
      header_height = Configuration.instance.header_font.line_height * 3
      signature_height = Configuration.instance.signature_font.line_height + 8
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |a|
          a.size "#{montage.width - 18}x1"
          a.xc Configuration.instance.header_background
          a.size.+
          if Configuration.instance.header_font.exists?
            a.font Configuration.instance.header_font.path
          end
          a.pointsize Configuration.instance.header_font.size
          a.background Configuration.instance.header_background
          a.fill Configuration.instance.header_color
          a.stack do |b|
            b.gravity 'West'
            b.stack do |c|
              c.label 'Filename: '
              if Configuration.instance.header_font.exists?
                c.font  Configuration.instance.header_font.path
              end
              c.label File.basename(@video.full_path)
              c.append.+
            end
            if Configuration.instance.header_font.exists?
              b.font Configuration.instance.header_font.path
            end
            b.label "File size: #{Tools.to_human_size(File.size(@video.full_path))}"
            b.label "Length: #{@length.to_timestamp}"
            b.append
            b.crop "#{montage.width}x#{header_height}+0+0"
          end
          a.append
          a.stack do |b|
            b.size "#{montage.width}x#{header_height}"
            b.gravity 'East'
            b.fill Configuration.instance.header_color
            b.annotate '+0-1'
            b << "Dimensions: #{@video.video.width}x#{@video.video.height}\nFormat: #{@video.video.codec(true)} / #{@video.audio.codec(true)}\nFPS: #{"%.02f" % @video.video.frame_rate.to_f}"
          end
          a.bordercolor Configuration.instance.header_background
          a.border 9
        end
        convert << create_title(montage) if @title
        convert << create_highlight(montage) if @highlight
        convert << montage.path
        convert.append
        if @signature
          convert.stack do |a|
            a.size "#{montage.width}x#{signature_height}"
            a.gravity 'Center'
            a.xc Configuration.instance.signature_background
            if Configuration.instance.signature_font.exists?
              a.font Configuration.instance.signature_font.path
            end
            a.pointsize Configuration.instance.signature_font.size
            a.fill Configuration.instance.signature_color
            a.annotate(0, @signature)
          end
          convert.append
        end
        if format == :jpg || format == :jpeg
          convert.quality(Configuration.instance.quality)
        end
        convert << file_path
      end
      file_path
    end
  end
end
