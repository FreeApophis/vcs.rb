
# Contact Sheet Composited from the Thumbnails
#

require 'tmpdir'
require 'font'
require 'tools'
require 'thumbnail'
require 'time_index'
require 'libav'	
require 'mplayer'
require 'ffmpeg'	

module VCSRuby
  class ContactSheet 
    attr_accessor :capturer
    attr_reader :rows, :columns, :interval
    attr_reader :thumbnail_width, :thumbnail_height, :thumbnail_aspect
    
    attr_reader :length
    attr_accessor :to, :from
    
    def initialize video
      @video = video
      initialize_capturers
      detect_video_properties
      
      @thumbnails = []

      @rows = 4
      @columns = 4
      @number_of_caps = 16
      @interval = @length /17
      @tempdir = Dir.mktmpdir
      @standard_font = Font.new 'DejaVuSans'
    end

    def selected_capturer
      @capturers.first
    end

    def initialize_capturers
      capturers = []
      capturers << LibAV.new(@video)
      capturers << MPlayer.new(@video)
      capturers << FFmpeg.new(@video)

      @capturers = capturers.select{ |c| c.available? }
      puts "Available capturers: #{@capturers.map{ |c| c.to_s }.join(', ')}"
    end

    def build
      initialize_thumbnails
      
      @thumbnails.each_with_index do |thumbnail, i|
        puts "Generating capture #{i + 1}/#{@number_of_caps}" unless Tools::quiet?
        thumbnail.capture
        thumbnail.apply_filters
      end


      MiniMagick::Tool::Montage.new do |montage|
        montage.background 'Transparent'
        @thumbnails.each do |thumbnail|
          montage << thumbnail.image_path
        end
        montage.geometry "+#{0}+#{0}"             # Zwischenraum
        montage.tile "#{@columns}x#{@rows}" # 
        montage << File::join(@tempdir, "montage.png")
      end

      MiniMagick::Tool::Convert.new do |convert|
        convert << File::join(@tempdir, "montage.png")
        convert.background 'Transparent'
        convert.splice '5x10'      
        convert << File::join(@tempdir, "spliced.png")
      end    

      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |ul|
          ul.size '1000x40'
          ul << 'xc:White'
          ul.font @standard_font.full_path
          ul.pointsize 33
          ul.background 'White'
          ul.fill 'Black'
          ul.gravity 'Center'
          ul.annotate(0, 'This is a Title!!!')
        end
        convert.flatten
        convert << File::join(@tempdir, "title.png")
      end

      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |a|
          a.size '771x1'
          a.xc '#afcd7a'
          a.size.+
          a.font @standard_font.full_path
          a.pointsize 14
          a.background '#afcd7a'
          a.fill 'Black'
          a.stack do |b|
            b.gravity 'West'
            b.stack do |c|
              c.label 'Filename: '
              c.font @standard_font.full_path
              c.label @video
              c.append.+
            end
            b.font @standard_font.full_path
            b.label "File size: #{Tools.to_human_size(File.size(@video))}"
            b.label "Length: #{@length}"
            b.append
            b.crop '789x51+0+0'
          end
          a.append
          a.stack do |b|
            b.size '789x51'
            b.gravity 'East'
            b.fill 'Black'
            b.annotate '+0-1'
            b << "Dimensions: #{selected_capturer.width}x#{selected_capturer.height}\nFormat: #{selected_capturer.video_codec} / #{selected_capturer.audio_codec}\nFPS: #{selected_capturer.fps}"
          end
          a.bordercolor '#afcd7a'
          a.border 9
        end
        convert << File::join(@tempdir, "montage.png")
        convert.append
        convert.stack do |a|
          a.size '789x28'
          a.gravity 'Center'
          a.xc 'SlateGray'
          a.font @standard_font.full_path
          a.pointsize 10
          a.fill 'Black'
          a.annotate(0, 'Preview created by vcs.rb')
        end
        convert.append
        convert << File::join(@tempdir, "final.png")
      end

    end


    def input_format
    end
    
    def output_format
    end
    
    # Use this method to initialize the number of frames
    # The Method allows exactly two parameters of the four
    # All others must be nil and will be calculated
    def frames(rows, columns, numcaps, interval)
      raise "ONLY 2 PARAMETERS ALLOWED" unless local_variables.map{ |v| eval(v.to_s) ? 1 : 0 }.reduce(0, &:+) == 2
      if (rows && columns)
        @rows = rows
        @columns = columns
        @number_of_caps = rows * columns
        @interval = @length / @number_of_caps + 1
      end
    end
    
    def thumbnail_width= width
    end

    def thumbnail_height= height
    end
    
    def thumbnail_aspect= aspect
    end
    
    def mode
      [:polaroid, :photos, :overlap, :rotate, :photoframe, :polaroidframe, :film, :random]
    end
    
private
    def initialize_thumbnails
      time = TimeIndex.new 0.0
      (1..@number_of_caps).each do |i|
        thumb = Thumbnail.new selected_capturer, @video

        thumb.width = thumbnail_width
        thumb.height = thumbnail_height
        thumb.time = (time += @interval)
        thumb.image_path = File::join(@tempdir, "th#{"%03d" % i}.png")

        @thumbnails << thumb
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
  end
end
