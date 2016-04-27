#
# Font helper
#

require 'mini_magick'

module VCSRuby
  class Font
    attr_reader :name, :path, :size

    def initialize name, size
      @name = name
      @path = find_path
      @size = size
    end

    def find_path
      '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf'
    end

    def line_height
      MiniMagick::Tool::Convert.new do |convert|
        convert.font path
        convert.pointsize size
        convert << 'label:F'
        convert.format '%h'
        convert << 'info:'
      end.to_i
    end
  end
end
