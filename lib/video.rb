#
# Represents the video file
#

module VCSRuby
  class Video
    attr_reader :config

    def initialize video
      initialize_filename video
      initialize_capturers
    end

    def valid?
      capturer.file_valid?
    end

    def info
      capturer.info
    end

    def video
      capturer.video_streams.first
    end

    def video_streams
      capturer.video_streams
    end

    def audio
      capturer.audio_streams.first
    end

    def audio_streams
      capturer.audio_streams
    end

    def full_path
      File.join(@path, @filename)
    end

    def contact_sheet
      @contact_sheet ||= ContactSheet.new self, capturer
    end

    def frame time_index
      return Frame.new self, capturer, time_index
    end
    
    def capturer_name
      capturer.name
    end

private
    def initialize_filename video
      @path = File.dirname(File.absolute_path(video))
      @filename = File.basename(video)
    end

    def initialize_capturers
      @capturers = []

      @capturers << LibAV.new(self)
      @capturers << MPlayer.new(self)
      @capturers << FFmpeg.new(self)

      if Configuration.instance.verbose?
        puts "Available capturers: #{available_capturers.map{ |c| c.to_s }.join(', ')}"
      end
    end

    def available_capturers
      @capturers.select{ |c| c.available? }
    end

    def capturer
      result = nil
      if Configuration.instance.capturer == :mock
        result = MockCapturer.new(self)
      elsif Configuration.instance.capturer == :any
        result = available_capturers.first
      else
        result = available_capturers.select{ |c| c.name == Configuration.instance.capturer }.first
      end

      unless result
        raise "Selected Capturer (#{Configuration.instance.capturer}) not available. Install one of these: #{@capturers.map{ |c| c.name }.join(', ')}"
      end

      return result
    end
  end
end
