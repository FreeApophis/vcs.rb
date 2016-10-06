#
# Capturer Baseclass
#

require 'vcs'

module VCSRuby
  class Capturer
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
      @format
    end

    def format= format
      if available_formats.include? format
        @format = format
      else
        raise "Capturer '#{name}' does not support format: '#{format}'"
      end
    end
  end
end
