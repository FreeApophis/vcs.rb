#
# Capturer Baseclass
#

module VCSRuby
  class Capturer
    def available?
      false
    end

    def name
      raise "NotImplementedException"
    end

    def load_video
      raise "NotImplementedException"
    end

    def length
      raise "NotImplementedException"
    end

    def width
      raise "NotImplementedException"
    end

    def height
      raise "NotImplementedException"
    end

    def grab time, image_path
      raise "NotImplementedException"
    end
  end
end
