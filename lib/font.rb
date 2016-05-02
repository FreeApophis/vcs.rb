#
# Font helper
#

require 'mini_magick'
require 'pp'

module VCSRuby
  IMFont = Struct.new(:name, :family, :style, :stretch, :weight, :glyphs)

  class Font
    attr_reader :name, :path, :size

    @@fonts = {}
    
    def initialize name, size
      @name = name
      @path = find_path
      @size = size
    end
    
    def exists?
      load_font_cache if @@fonts.length == 0
      
      !!font_by_name(@name)
    end
    
    def find_path
      load_font_cache if @@fonts.length == 0
      
      if exists?
        font_by_name(@name).glyphs
      else
        nil
      end
    end
    
    def font_by_name name
      if name =~ /\./
        key, font = @@fonts.select{ |key, f| f.glyphs =~ /#{name}\z/ }.first
        return font
      else
        @@fonts[name]
      end
    end
    
    def load_font_cache
     
      fonts = MiniMagick::Tool::Identify.new(whiny: false) do |identify|
        identify.list 'font'
      end

      parse_fonts(fonts)
    end
    
    def parse_fonts(fonts)
      font = nil
      fonts.lines.each do |line|
        key, value = line.strip.split(':', 2).map(&:strip)
        
        next if [nil, 'Path'].include? key

        if key == 'Font'
          @@fonts[value] = font = IMFont.new(value) 
        else           
          font.send("#{key}=", value)
        end
      end
    end

    def line_height
      MiniMagick::Tool::Convert.new do |convert|
        convert.font path if exists?
        convert.pointsize size
        convert << 'label:F'
        convert.format '%h'
        convert << 'info:'
      end.to_i
    end
  end
end
