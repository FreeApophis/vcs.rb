#
# Contact Sheet Composited from the Thumbnails
#

require 'fileutils'
require 'tmpdir'
require 'yaml'

require 'vcs'

module VCSRuby
  class ContactSheet
    attr_accessor :capturer, :format, :signature, :title, :highlight
    attr_reader :thumbnail_width, :thumbnail_height
    attr_reader :length, :from, :to

    def initialize video, capturer = :any
      @capturer = capturer
      @configuration = Configuration.new
      @signature = "Created by Video Contact Sheet Ruby"
      initialize_capturers video
      initialize_filename(File.basename(@video, '.*'))
      puts "Processing #{File.basename(video)}..." unless Tools.quiet?
      detect_video_properties

      @thumbnails = []

      @tempdir = Dir.mktmpdir

      ObjectSpace.define_finalizer(self, self.class.finalize(@tempdir) )

      initialize_geometry(@configuration.rows, @configuration.columns, @configuration.interval)
    end

    def initialize_filename filename
      @out_path = File.dirname(filename)
      @out_filename = File.basename(filename,'.*')
      ext = File.extname(filename).gsub('.', '')
      if ['png', 'jpg', 'jpeg', 'tiff'].include?(ext)
        @format ||= ext.to_sym
      end
    end

    def filename
      "#{@out_filename}.#{@format ? @format.to_s : 'png'}"
    end

    def full_path
      File.join(@out_path, filename)
    end

    def initialize_geometry(rows, columns, interval)
      @has_interval = !!interval
      @rows = rows
      @columns = columns
      @interval = interval
    end

    def rows
      @rows
    end

    def columns
      @columns
    end

    def interval
      @interval || (@to - @from) / (number_of_caps + 1)
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


    def self.finalize(tempdir)
      proc do
        puts "Cleaning up..." unless Tools.quiet?
        FileUtils.rm_r tempdir
      end
    end

    def build
      initialize_thumbnails
      capture_thumbnails

      puts "Composing standard contact sheet..." unless Tools.quiet?
      s = splice_montage(montage_thumbs)

      image = MiniMagick::Image.open(s)

      puts "Adding header and footer..." unless Tools.quiet?
      final = add_header_and_footer image

      puts "Done. Output wrote to '#{filename}'" unless Tools.quiet?
      FileUtils.mv(final, full_path)
    end


private
    def selected_capturer
      result = nil
      if @capturer == nil || @capturer == :any
        result = @capturers.first
      else
        result =  @capturers.select{ |c| c.name == @capturer }.first
      end
      raise "Selected Capturer (#{@capturer.to_s}) not available" unless result
      return result
    end

    def initialize_capturers video
      capturers = []
      capturers << LibAV.new(video)
      capturers << MPlayer.new(video)
      capturers << FFmpeg.new(video)

      @video = video
      @capturers = capturers.select{ |c| c.available? }

      puts "Available capturers: #{@capturers.map{ |c| c.to_s }.join(', ')}" if Tools.verbose?
    end

    def initialize_thumbnails
      time = @from
      (1..number_of_caps).each do |i|
        thumb = Thumbnail.new selected_capturer, @video, @configuration

        thumb.width = thumbnail_width
        thumb.height = thumbnail_height
        thumb.time = (time += interval)
        thumb.image_path = File::join(@tempdir, "th#{"%03d" % i}.png")

        @thumbnails << thumb
      end
    end

    def capture_thumbnails
      puts "Capturing in range [#{from}..#{to}]. Total length: #{@length}" unless Tools.quiet?

      @thumbnails.each_with_index do |thumbnail, i|
        puts "Generating capture ##{i + 1}/#{number_of_caps} #{thumbnail.time}..." unless Tools::quiet?
        if @configuration.blank_evasion?
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
      @length = selected_capturer.length

      @from = TimeIndex.new 0.0
      @to = @length
    end

    def detect_dimensions
      @thumbnail_width = selected_capturer.width
      @thumbnail_height = selected_capturer.height
    end

    def montage_thumbs
      file_path = File::join(@tempdir, 'montage.png')
      MiniMagick::Tool::Montage.new do |montage|
        montage.background @configuration.contact_background
        @thumbnails.each do |thumbnail|
          montage << thumbnail.image_path
        end
        montage.geometry "+#{@configuration.padding}+#{@configuration.padding}"
        # rows or columns can be nil (auto fit)
        montage.tile "#{@columns}x#{@rows}"
        montage << file_path
      end
      return file_path
    end

    def splice_montage montage_path
      file_path = File::join(@tempdir, 'spliced.png')
      MiniMagick::Tool::Convert.new do |convert|
        convert << montage_path
        convert.background @configuration.contact_background
        convert.splice '5x10'
        convert << file_path
      end
      file_path
     end

    def create_title montage
      file_path = File::join(@tempdir, 'title.png')
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |ul|
          ul.size "#{montage.width}x#{@configuration.title_font.line_height}"
          ul.xc @configuration.title_background
          ul.font @configuration.title_font.path
          ul.pointsize @configuration.title_font.size
          ul.background @configuration.title_background
          ul.fill @configuration.title_color
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
      thumb = Thumbnail.new selected_capturer, @video, @configuration

      thumb.width = thumbnail_width
      thumb.height = thumbnail_height
      thumb.time = @highlight
      thumb.image_path = File::join(@tempdir, "highlight_thumb.png")
      thumb.capture
      thumb.apply_filters

      file_path =  File::join(@tempdir, "highlight.png")
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |a|
          a.size "#{montage.width}x#{thumbnail_height+20}"
          a.xc @configuration.highlight_background
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
      header_height = @configuration.header_font.line_height * 3
      signature_height = @configuration.signature_font.line_height + 8
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |a|
          a.size "#{montage.width - 18}x1"
          a.xc @configuration.header_background
          a.size.+
          a.font @configuration.header_font.path
          a.pointsize @configuration.header_font.size
          a.background @configuration.header_background
          a.fill 'Black'
          a.stack do |b|
            b.gravity 'West'
            b.stack do |c|
              c.label 'Filename: '
              c.font  @configuration.header_font.path
              c.label File.basename(@video)
              c.append.+
            end
            b.font @configuration.header_font.path
            b.label "File size: #{Tools.to_human_size(File.size(@video))}"
            b.label "Length: #{@length.to_timestamp}"
            b.append
            b.crop "#{montage.width}x#{header_height}+0+0"
          end
          a.append
          a.stack do |b|
            b.size "#{montage.width}x#{header_height}"
            b.gravity 'East'
            b.fill @configuration.header_color
            b.annotate '+0-1'
            b << "Dimensions: #{selected_capturer.width}x#{selected_capturer.height}\nFormat: #{selected_capturer.video_codec} / #{selected_capturer.audio_codec}\nFPS: #{"%.02f" % selected_capturer.fps}"
          end
          a.bordercolor @configuration.header_background
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
            a.xc @configuration.signature_background
            a.font @configuration.signature_font.path
            a.pointsize @configuration.signature_font.size
            a.fill @configuration.signature_color
            a.annotate(0, @signature)
          end
          convert.append
        end
        if format == :jpg || format == :jpeg
          convert.quality(@configuration.quality)
        end
        convert << file_path
      end
      file_path
    end
  end
end
