#
# MPlayer Abstraction
#

require 'command'
require 'capturer'
require 'fileutils'

module VCSRuby
  class MPlayer < Capturer

    HEADER = 2

    def initialize video
      @video = video
      @mplayer = Command.new :mplayer, 'mplayer'

      detect_version if available?
    end

    def name
      :mplayer
    end

    def available?
      @mplayer.available?
    end
    
    def detect_version
      info = @mplayer.execute('')
      match = /MPlayer (.*),/.match(info)
      @version = match[1] if match
    end

    def length
      load_probe
      @length
    end

    def width
      load_probe
      @width
    end

    def height
      load_probe
      @height
    end

    def video_codec
      load_probe
      @video_codec
    end

    def audio_codec
      load_probe
      @audio_codec
    end

    def fps
      load_probe
      @fps
    end

    def file_pattern n
      if format == :jpeg
        "#{"%08d" % n}.jpg"
      else
        "#{"%08d" % n}.#{format.to_s}"
      end
    end

    def grab time, image_path
      @mplayer.execute "-sws 9 -ao null -benchmark -vo #{@format} -quiet -frames 5 -ss #{time.total_seconds} \"#{@video}\""
      (1..4).each { |n| FileUtils.rm(file_pattern(n)) }
      FileUtils.mv(file_pattern(5), image_path)      
    end

    def available_formats
      # Ordered by priority
      image_formats = ['png', 'jpeg']
      formats = []

      list = @mplayer.execute("-vo help", 0, true)
      list.lines.drop(HEADER).each do |codec|
        name = format_split(codec)
        formats << name if image_formats.include?(name)
      end

      image_formats.select{ |format| formats.include?(format) }.map(&:to_sym)
    end

    def format_split line
      name = line.strip.split(' ', 2).first
    end

    def to_s
      "MPlayer #{@version}"
    end
  private
    def parsed?
      !!@parsed
    end

    def load_probe
      unless parsed?
        parse_identify(@mplayer.execute("-ao null -vo null -identify -frames 0 -quiet \"#{@video}\""))
      end
    end

    def parse_identify info
      info.lines.each do |line|
        key, value = line.split('=', 2)
        @length = TimeIndex.new value.to_f if key == 'ID_LENGTH'
        @width = value.to_i if key == 'ID_VIDEO_WIDTH'
        @height = value.to_i if key == 'ID_VIDEO_HEIGHT'
        @video_codec = value.chomp if key == 'ID_VIDEO_FORMAT'
        @audio_codec = value.chomp if key == 'ID_AUDIO_FORMAT'
        @fps = value.to_f if key == 'ID_VIDEO_FPS'
      end
      @parsed = true
    end
  end
end
