#
# Contact Sheet Composited from the Thumbnails
#

require 'thumbnail'
require 'commands'

module VCSRuby
  class ContactSheet 
    attr_reader :rows, :columns, :interval
    attr_reader :thumbnail_width, :thumbnail_height, :thumbnail_aspect
    
    attr_reader :length
    attr_reader :capturer
    
    def initialize video
      @commands = Commands.new
      
      @video = video
      @thumbails = []
    end

    def capturer= capturer
      case capturer
        when :any
          @capturer = @commands.best_capturer         
        when :ffmpeg
          @capturer = @commands.ffmpeg
        when :libav
          @capturer = @commands.libav
        when :mplayer
          @capturer = @commands.mplayer
      end
    end

    def capturer
    end

    def create
    end
    
    def input_format
    end
    
    def output_format
    end
    
    def rows=
    end
    
    def columns= columns
      @columns = columns
    end
    
    def number_of_caps= caps
      @number_of_caps = caps
      @columns = caps / @rows
    end
    
    def interval=
    end
    
    def from=
    end
    
    def to=
    end
       
    def thumbnail_width
    end

    def thumbnail_height
    end
    
    def thumbnail_aspect
    end
    
    def mode
      [:polaroid, :photos, :overlap, :rotate, :photoframe, :polaroidframe, :film, :random]
    end
    
private
    def  calculate_number_of_caps
      @number_of_caps = @rows * @columns
    end
    
    def  calculate_interval

    end

  end
end
