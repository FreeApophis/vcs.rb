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
      match = /avconv ([\d|\.|\-|:]*)/.match(info)
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

    def check_cache
      unless @cache
        @cache = @avprobe.execute("\"#{@video.full_path}\"  -show_format -show_streams", "2>&1")
      end
    end

    def extract_format regexp
      @cache.scan(regexp) do |format|
        @info = LibAVMetaInfo.new(get_hash(format[0]))
        return true
      end
      false
    end

    def parse_format
      parsed = extract_format(/\[FORMAT\](.*?)\[\/FORMAT\]/m)
      unless parsed
        parsed = extract_format(/\[format\](.*?)\n\n/m)
      end
      return parsed
    end

    def extract_audio_streams regexp
      parsed = false
      @cache.scan(regexp) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'audio'
          @audio_streams << LibAVAudioStream.new(info)
          parsed = true
        end
      end
      parsed
    end

    def parse_audio_streams
      @audio_streams = []
      parsed = extract_audio_streams(/\[STREAM\](.*?)\[\/STREAM\]/m)
      unless parsed
        extract_audio_streams(/\[streams.stream.\d\](.*?)\n\n/m)
      end
      true
    end

    def extract_video_streams regexp
      parsed = false
      @cache.scan(regexp) do |stream|
        info = get_hash(stream[0])
        if info['codec_type'] == 'video'
          @video_streams << LibAVVideoStream.new(info)
          parsed = true
        end
      end
      parsed
    end

    def parse_video_streams
      @video_streams = []
      parsed = extract_video_streams(/\[STREAM\](.*?)\[\/STREAM\]/m)
      unless parsed
        parsed = extract_video_streams(/\[streams.stream.\d\](.*?)\n\n/m)
      end
      true
    end
  end
end
