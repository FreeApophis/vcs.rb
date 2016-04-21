#
# Capturer Baseclass
#


module VCSRuby
  class Capturer
    def available?
      false
    end

    def load_video
      raise "NotImplmentedException"
    end

    def length
      raise "NotImplmentedException"
    end
  
    def width
      raise "NotImplmentedException"
    end
  
    def height
      raise "NotImplmentedException"
    end

    def aspect_ratio
    end
  end
end
