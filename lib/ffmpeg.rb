#
# FFmpeg Abstraction
#

require 'capturer'
require 'command'
require 'time_index'

module VCSRuby
  class FFmpeg < Capturer

    HEADER = 10
    ENCODING_SUPPORT = 2
    VIDEO_CODEC = 3
    NAME = 8
    
    attr_reader :format, :video_streams, :audio_streams

    def initialize video
      @video = video
      @ffmpeg = Command.new :ffmpeg, 'ffmpeg'
      @ffprobe = Command.new :ffmpeg, 'ffprobe'
      
      detect_version if available?
    end
       
    def valid?
      return probe_meta_information
    end

    def name
      :ffmpeg
    end

    def available?
      @ffmpeg.available? && !libav?
    end

    def libav?
      @libav
    end

    def detect_version
      info = @ffmpeg.execute('-version')
      match = /avconv ([\d|.|-|:]*)/.match(info)
      @libav = true if match
      match = /ffmpeg version ([\d|.]*)/.match(info)
      if match
        @version = match[1]
      end
    end

    def grab time, image_path
      @ffmpeg.execute "-y -ss #{time.total_seconds} -i \"#{@video.full_path}\" -an -dframes 1 -vframes 1 -vcodec png -f rawvideo \"#{image_path}\""
    end

    def available_formats
      # Ordered by priority
      image_formats = ['png', 'tiff', 'bmp', 'mjpeg']
      formats = []

      list = @ffprobe.execute "-codecs"
      list.lines.drop(HEADER).each do |codec|
        name, e, v = format_split(codec)
        formats << name if image_formats.include?(name) && e && v
      end

      image_formats.select{ |format| formats.include?(format) }.map(&:to_sym)
    end

    def to_s
      "FFmpeg #{@version}"
    end

private
    def format_split line
      e = line[ENCODING_SUPPORT] == 'E'
      v = line[VIDEO_CODEC] == 'V'

      name = line[NAME..-1].split(' ', 2).first
      return name, e, v
    rescue
      return nil, false, false
    end

    def probe_meta_information
      return true if @cache

      @cache = @ffprobe.execute("\"#{@video.full_path}\"  -show_format -show_streams", "2>&1")
      puts @cache if Configuration.instance.verbose?

      parse_meta_info
      return true
    rescue Exception => e
      puts e
      return false
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
      format = /\[FORMAT\](.*?)\[\/FORMAT\]/m.match(@cache)
      if format       
        @format = get_hash(format[1])
      end
      @video_streams = []
      @audio_streams = []
      @cache.scan(/\[STREAM\](.*?)\[\/STREAM\]/m) do |stream|
        hash = get_hash(stream[0])
        @video_streams << hash if hash['codec_type'] == 'video'
        @audio_streams << hash if hash['codec_type'] == 'audio'
      end
      puts @video_streams.count
      puts @audio_streams.count
    end
  end
end
