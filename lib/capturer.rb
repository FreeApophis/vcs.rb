#
# Capturer Baseclass
#

require 'vcs'

module VCSRuby
  class Capturer
    $formats = { :png => 'png', :bmp => 'bmp', :tiff => 'tif', :mjpeg => 'jpg', :jpeg => 'jpg', :jpg => 'jpg' }

    def available?
      false
    end

    def self.initialize_capturers video
      capturers = []

      puts "Available capturers: #{available_capturers.map{ |c| c.to_s }.join(', ')}" if Tools.verbose?
    end

    def self.create
      capturers = []

      capturers << LibAV.new(video)
      capturers << MPlayer.new(video)
      capturers << FFmpeg.new(video)

      return capturers.first
    end

    def format
      @format || available_formats.first
    end

    def format_extension
      $formats[format]
    end

    def format= format
      if available_formats.include? format
        @format = format
      else
        raise "Capturer '#{name}' does not support format: '#{format}'"
      end
    end

  private
    def probe_meta_information
      check_cache
      return parse_meta_info
    rescue Exception => e
      puts e
      return false
    end

    def parse_meta_info
      parse_format && parse_audio_streams && parse_video_streams
    end

    def get_hash defines
      result = {}
      defines.lines.each do |line|
        kv = line.split("=")
        result[kv[0].strip] = kv[1].strip if kv.count == 2
      end
      result
    end
  end
end
