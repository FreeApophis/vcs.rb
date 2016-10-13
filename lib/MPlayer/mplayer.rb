#
# MPlayer Abstraction
#

require 'capturer'
require 'command'

module VCSRuby
  class MPlayer < Capturer

    HEADER = 2

    attr_reader :info, :video_streams, :audio_streams
    def initialize video
      @video = video
      @mplayer = Command.new :mplayer, 'mplayer'

      detect_version if available?
    end

    def file_valid?
      return probe_meta_information
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

    def grab time, image_path
      @mplayer.execute "-sws 9 -ao null -benchmark -vo #{@format} -quiet -frames 5 -ss #{time.total_seconds} \"#{@video.full_path}\""
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

    def to_s
      "MPlayer #{@version}"
    end

  private
    def format_split line
      name = line.strip.split(' ', 2).first
    end
    def probe_meta_information
      check_cache
      parse_meta_info
      return true
    rescue Exception => e
      puts e
      return false
    end

    def check_cache
      unless @cache
        @cache = @mplayer.execute("-ao null -vo null -identify -frames 0 -really-quiet \"#{@video.full_path}\"")
      end
    end

    def get_hash defines
      result = {}
      defines.lines.each do |line|
        kv = line.split("=")
        result[kv[0].strip] = kv[1].strip if kv.count == 2
      end
      result
    end

    def parse_meta_info
      mplayer_hash = get_hash(@cache)
      @info = MPlayerMetaInfo.new(mplayer_hash, File.size(@video.full_path))

      # Todo: Handling of multiple streams
      @info = [ MPlayerVideoStream.new(get_hash(mplayer_hash) ]
      @info = [ MPlayerAudioStream.new(get_hash(mplayer_hash) ]
    end

    def file_pattern n
      if format == :jpeg
        "#{"%08d" % n}.jpg"
      else
        "#{"%08d" % n}.#{format.to_s}"
      end
    end
  end
end
