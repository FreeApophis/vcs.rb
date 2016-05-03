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

    def available_formats
      raise "NotImplementedException"
    end

    def format
      @format
    end

    def format= format
      if available_formats.include? format
        @format = format
      else
        raise "Capturer '#{name}' does not support format: '#{format}'"
      end
    end
  end
end
