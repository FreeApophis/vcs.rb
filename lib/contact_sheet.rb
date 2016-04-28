#
# Contact Sheet Composited from the Thumbnails
#

require 'fileutils'
require 'tmpdir'
require 'yaml'

require 'vcs'

module VCSRuby
  class ContactSheet 
    attr_accessor :capturer, :format, :signature
    attr_reader :thumbnail_width, :thumbnail_height
    attr_reader :rows, :columns, :number_of_caps, :interval
    attr_reader :length
      
    def initialize video
      @configuration = Configuration.new
      @signature = "Created by Video Contact Sheet Ruby"
      initialize_capturers video
      puts "Processing #{File.basename(video)}..." unless Tools.quiet?
      detect_video_properties
      
      @thumbnails = []

      @tempdir = Dir.mktmpdir

      ObjectSpace.define_finalizer(self, self.class.finalize(@tempdir) )

      initialize_geometry(@configuration.rows, @configuration.columns, @configuration.number_of_caps, @configuration.interval)
    end

    def initialize_geometry(rows, columns, number_of_caps, interval)
      if rows && columns
        puts "geometry based on rows and columns set..."
        rows = rows.to_i
        columns = columns.to_i
        @rows = rows
        @columns = columns
        @number_of_caps = rows * columns
        @interval = @length / (rows * columns)
        return
      end
      if number_of_caps && columns
        puts "geometry based on caps and columns set..."
        number_of_caps = number_of_caps.to_i
        columns = columns.to_i
        @rows = (number_of_caps / columns).to_i
        @columns = columns
        @number_of_caps = number_of_caps
        @interval = @length / number_of_caps
        return
      end
      if number_of_caps && rows
        puts "geometry based on caps and rows set..."
        number_of_caps = number_of_caps.to_i
        rows = rows.to_i
        @rows = rows
        @columns = (number_of_caps / rows).to_i
        @number_of_caps = number_of_caps
        @interval = @length / number_of_caps
        return
      end
      if interval && columns
        puts "geometry based on interval and columns set..."
        inteval = TimeIndex.new interval
        columns = columns.to_i
        @number_of_caps = (@length / interval).to_i
        @rows = (@number_of_caps / columns).to_i
        @columns = columns
        @interval = interval
        return
      end
      if interval && rows
        puts "geometry based on interval and rows set..."
        inteval = TimeIndex.new interval
        rows = rows.to_i
        @number_of_caps = (@length / interval).to_i
        @rows = rows
        @columns = (@number_of_caps / rows).to_i
        @interval = interval
        return
      end

      raise "At least two useful geometry parameters must be set."
    end

    def thumbnail_width= width
      @thumbnail_height = (width.to_f / @thumbnail_width * thumbnail_height).to_i
      @thumbnail_width = width
    end

    def thumbnail_height= height
      @thumbnail_width = (height.to_f / @thumbnail_height * thumbnail_width).to_i
      @thumbnail_height = height
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

      create_title image if @title

      puts "Adding header and footer..." unless Tools.quiet?
      final = add_header_and_footer image

      filename = File.basename(@video) + ".#{format.to_s}"
      puts "Done. Output wrote to '#{filename}'" unless Tools.quiet?
      FileUtils.mv(final, filename)
    end


private
    def selected_capturer
      if @capturer == nil || @capturer == :any
        return @capturers.first
      else
        return @capturers.select{ |c| c.name == @capturer }
      end
      raise "Selected Capturer (#{@capturer}) not available"
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
      time = TimeIndex.new 0.0
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
      puts "Capturing in range [TODO]. Total length: #{@length}" unless Tools.quiet?

      @thumbnails.each_with_index do |thumbnail, i|
        puts "Generating capture ##{i + 1}/#{@number_of_caps} #{thumbnail.time}..." unless Tools::quiet?
        if @configuration.blank_evasion?
          thumbnail.capture_and_evade @interval
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
        montage.geometry "+#{2}+#{2}"             # Zwischenraum
        montage.tile "#{@columns}x#{@rows}" # 
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

    def create_title montage, title
      file_path = File::join(@tempdir, 'title.png')
      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |ul|
          ul.size "#{montage.width}x#{@title_font.line_height}"
          ul.xc @configuration.title_background
          ul.font @configuration.title_font.path
          ul.pointsize @configuration.title_font.size
          ul.background @configuration.title_background
          ul.fill @configuration.title_color
          ul.gravity 'Center'
          ul.annotate(0, title)
        end
        convert.flatten
      end
      return file_path
    end

    def add_header_and_footer montage
      file_path = File::join(@tempdir, "final.#{format}")
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
            b << "Dimensions: #{selected_capturer.width}x#{selected_capturer.height}\nFormat: #{selected_capturer.video_codec} / #{selected_capturer.audio_codec}\nFPS: #{selected_capturer.fps}"
          end
          a.bordercolor @configuration.header_background
          a.border 9
        end
        convert << montage.path
        convert.append
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
        convert << file_path
      end
      file_path
    end
  end
end
