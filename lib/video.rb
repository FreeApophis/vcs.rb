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
      capturer.file_valid?
    end

    def streams
      capturer.streams
    end
    
    def video_streams
      capturer.streams.select{ |stream| stream.codec_type == 'video' }
    end
    
    def audio_streams
      capturer.streams.select{ |stream| stream.codec_type == 'audio' }
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

    def video_codec
      video_streams.first.codec_long_name
    end

    def color_space
      video_streams.first.color_space
    end

    def resolution
      "#{video_streams.first.width}x#{video_streams.first.height}"
    end

    def width
      video_streams.first.width.to_i
    end

    def height
      video_streams.first.height.to_i
    end

    def frame_rate
      parts = video_streams.first.r_frame_rate.split('/')
      return parts[0].to_f / parts[1].to_f
    end

    def audio_codec
      audio_streams.first.codec_long_name
    end

    def audio_sample_rate
      audio_streams.first.sample_rate
    end

    def audio_channels
      audio_streams.first.channels
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