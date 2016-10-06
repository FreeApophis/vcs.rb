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

    attr_reader :info, :video_streams, :audio_streams

    def initialize video
      @video = video
      @ffmpeg = Command.new :ffmpeg, 'ffmpeg'
      @ffprobe = Command.new :ffmpeg, 'ffprobe'

      detect_version if available?
    end

    def file_valid?
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
      check_cache
      parse_meta_info
      return true
    rescue Exception => e
      puts e
      return false
    end

    def check_cache
      unless @cache
        @cache = @ffprobe.execute("\"#{@video.full_path}\"  -show_format -show_streams", "2>&1")
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
      parse_format
      parse_audio_streams
      parse_video_streams
    end

    def parse_format
      @cache.scan(/\[FORMAT\](.*?)\[\/FORMAT\]/m) do |format|
        @info = FFmpegMetaInfo.new(get_hash(format[0]))
      end
    end

    def parse_audio_streams
      @audio_streams = []
      @cache.scan(/\[STREAM\](.*?)\[\/STREAM\]/m) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'audio'
          @audio_streams << FFmpegAudioStream.new(info)
        end
      end
    end

    def parse_video_streams
      @video_streams = []
      @cache.scan(/\[STREAM\](.*?)\[\/STREAM\]/m) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'video'
          @video_streams << FFmpegVideoStream.new(info)
        end
      end
    end


  end
end
