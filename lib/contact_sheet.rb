
# Contact Sheet Composited from the Thumbnails
#

require 'tmpdir'
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
      end

      font_path = '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf'

      MiniMagick::Tool::Convert.new do |convert|
        convert.stack do |ul|
          ul.size('1000x40')
          ul << 'xc:White'
          ul.font(font_path )
          ul.pointsize(33)
          ul.background('White')
          ul.fill('Black')
          ul.gravity('Center')
          ul.annotate(0, 'This is a Title!!!')
        end
        convert.flatten
        convert << 'example.png'
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
        thumb = Thumbnail.new @capturers.first, @video

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
      @length = @capturers.first.length

      @from = TimeIndex.new 0.0
      @to = @length
    end

    def detect_dimensions
      @thumbnail_width = @capturers.first.width
      @thumbnail_height = @capturers.first.height
#      @thumbnail_aspect = @capturers.first.aspect
    end
  end
end
