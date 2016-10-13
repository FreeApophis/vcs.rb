#
# libAV Abstraction
#

require 'capturer'
require 'command'

module VCSRuby
  class LibAV < Capturer

    HEADER = 10

    ENCODING_SUPPORT = 2
    VIDEO_CODEC = 3
    NAME = 8

    attr_reader :info, :video_streams, :audio_streams

    def initialize video
      @video = video
      @avconv = Command.new :libav, 'avconv'
      @avprobe = Command.new :libav, 'avprobe'

      detect_version if available?
    end

    def file_valid?
      return probe_meta_information
    end

    def name
      :libav
    end

    def available?
      @avconv.available? && @avprobe.available?
    end


    def detect_version
      info = @avconv.execute('-version')
      match = /avconv ([\d|.|-|:]*)/.match(info)
      if match
        @version = match[1]
      end
    end



    def grab time, image_path
      @avconv.execute "-y -ss #{time.total_seconds} -i \"#{@video.full_path}\" -an -dframes 1 -vframes 1 -vcodec #{format} -f rawvideo \"#{image_path}\""
    end

    def available_formats
      # Ordered by priority
      image_formats = ['png', 'tiff', 'bmp', 'mjpeg']
      formats = []

      list = @avprobe.execute "-codecs"
      list.lines.drop(HEADER).each do |codec|
        name, e, v = format_split(codec)
        formats << name if image_formats.include?(name) && e && v
      end

      image_formats.select{ |format| formats.include?(format) }.map(&:to_sym)
    end

    def to_s
      "LibAV #{@version}"
    end

private
    def format_split line
      correction = 0
      unless line[0] == ' '
        correction = 1
      end
      e = line[ENCODING_SUPPORT - correction] == 'E'
      v = line[VIDEO_CODEC - correction] == 'V'

      name = line[NAME-correction..-1].split(' ', 2).first
      return name, e, v
    rescue
      return nil, false, false
    end

    def probe_meta_information
      check_cache
      return parse_meta_info
    rescue Exception => e
      puts e
      return false
    end

    def check_cache
      unless @cache
        @cache = @avprobe.execute("\"#{@video.full_path}\"  -show_format -show_streams", "2>&1")
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
      parse_format && parse_audio_streams && parse_video_streams
    end

    def parse_format
      parsed = false
      @cache.scan(/\[FORMAT\](.*?)\[\/FORMAT\]/m) do |format|
        @info = LibAVMetaInfo.new(get_hash(format[0]))
        parsed = true
      end
      unless parsed
        @cache.scan(/\[format\](.*?)\n\n/m) do |format|
          @info = LibAVMetaInfo.new(get_hash(format[0]))
          parsed = true
        end
      end
      return parsed
    end

    def parse_audio_streams
      parsed = false
      @audio_streams = []
      @cache.scan(/\[STREAM\](.*?)\[\/STREAM\]/m) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'audio'
          @audio_streams << LibAVAudioStream.new(info)
          parsed = true
        end
      end
      unless parsed
        @cache.scan(/\[streams.stream.\d\](.*?)\n\n/m) do |stream|
          info = get_hash(stream[0])
          if info['codec_type'] == 'audio'
            @audio_streams << LibAVAudioStream.new(info)
            parsed = true
          end
        end
      end
      return parsed
    end

    def parse_video_streams
      parsed = false
      @video_streams = []
      @cache.scan(/\[STREAM\](.*?)\[\/STREAM\]/m) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'video'
          @video_streams << LibAVVideoStream.new(info)
          parsed = true
        end
      end
      unless parsed
        @cache.scan(/\[streams.stream.\d\](.*?)\n\n/m) do |stream|
          info = get_hash(stream[0])
          if info['codec_type'] == 'video'
            @vidio_streams << LibAVVidioStream.new(info)
            parsed = true
          end
        end
      end
      return parsed
    end
  end
end
