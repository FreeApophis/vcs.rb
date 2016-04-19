#
# Contact Sheet Composited from the Thumbnails
#

require 'thumbnail'

module VCSRuby
  class ContactSheet 
    attr_reader :rows, :columns, :interval
    
    attr_reader :length
    
    def initialize video
      @video = video
    end
    
    def input_format
    end
    
    def output_format
      :png
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
      [:polaroid, :photos, :overlap, :rotate, :photoframe, :polaroidframe, :film, random]
    end
    
private
    def  calculate_number_of_caps
      @number_of_caps = @rows * @columns
    end
    
    def  calculate_interval

    end

  end
end