#
# Capturer Baseclass
#

module VCSRuby
  class Capturer
    def available?
      false
    end

    def name
      raise "NotImplmentedException"
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

    def grab time
      raise "NotImplmentedException"
    end
  end
end
