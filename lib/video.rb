#
# Represents the video file
#

require 'vcs'

module VCSRuby
  class Video
    attr_reader :config
    
    def initialize video
      initialize_filename video
      initialize_capturers
    end

    def valid?
      capturer.valid?
    end

    def full_path
      File.join(@path, @filename)
    end
    
    def duration
      TimeIndex.new(capturer.format['duration'].to_f)
    end
    
    def bitrate
      capturer.format['bitrate'].to_i
    end

    def size
      capturer.format['size'].to_i
    end

    def video_stream
      capturer.video_streams.first
    end

    def video_codec
      capturer.video_streams.first['codec_long_name']      
    end

    def colorspace
      capturer.video_streams.first['color_space']
    end

    def resolution
      "#{capturer.video_streams.first['width']}x#{capturer.video_streams.first['height']}"
    end

    def width
      capturer.video_streams.first['width'].to_i
    end

    def height
      capturer.video_streams.first['height'].to_i
    end

    def frame_rate
      parts = capturer.video_streams.first['r_frame_rate'].split('/')
      return parts[0].to_f / parts[1].to_f
    end

    def audio_stream
      capturer.audio_streams.first
    end

    def audio_codec
      capturer.audio_streams.first['codec_long_name']      
    end

    def audio_sample_rate
      capturer.audio_streams.first['sample_rate']      
    end

    def audio_channels
      capturer.audio_streams.first['channels']      
    end

    def contact_sheet
      @contact_sheet ||= ContactSheet.new self
    end

    def frame time_index
      return Frame.new self, time_index
    end
    
    def capturer
      result = nil
      if Configuration.instance.capturer == :any
        result = available_capturers.first
      else
        result = available_capturers.select{ |c| c.name == Configuration.instance.capturer }.first
      end

      raise "Selected Capturer (#{@capturer.to_s}) not available. Install one of these: #{@capturers.map{ |c| c.name }.join(', ')}" unless result

      return result
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
  end
end