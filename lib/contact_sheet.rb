#
# Contact Sheet Composited from the Thumbnails
#

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
    
    def initialize video
      @video = video
      initialize_capturers
      detect_video_properties
      
      @thumbnails = []

      @rows = 4
      @columns = 4      
      @number_of_caps = 16
    end

    def initialize_capturers
      capturers = []
      capturers << LibAV.new(@video)
      capturers << MPlayer.new(@video)
      capturers << FFmpeg.new(@video)

      @capturers = capturers.select{ |c| c.available? }
      puts "Available Capturers: #{@capturers.map{ |c| c.to_s }.join(', ')}"
    end

    def build
      initialize_thumbnails
      @thumbnails.each do |thumbnail|
        thumbnail.capture
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
        @interval = 4.0
      end
    end
    
    def from=
    end
    
    def to=
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
      (1..@number_of_caps).each do |i|
        @thumbnails << Thumbnail.new
      end
    end

    def detect_video_properties
      detect_length
      detect_dimensions
    end

    def detect_length
      @capturers.each do |cap|
        return cap.length
      end
    end
  end
end
