#
# Font helper
#

require 'mini_magick'

module VCSRuby
  class Font
    attr_reader :name

    def initialize name
      @name = name
    end

    def full_path
      '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSans.ttf'
    end

    def line_height pointsize
      MiniMagick::Tool::Convert.new do |convert|
        convert.font full_path
        convert.pointsize pointsize
        convert << 'label:F'
        convert.format '%h'
        convert << 'info:'
      end.to_i
    end
  end
end
