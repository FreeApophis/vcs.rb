#
# Mock Implementation for Tests
#

require 'capturer'
require 'command'

module VCSRuby
  class MockCapturer < Capturer
    attr_reader :info, :video_streams, :audio_streams

    def initialize video
      @video = video
      @info = nil
      @video_streams = nil
      @audio_streams = nil
    end

    def file_valid?
      true
    end

    def name
      :mock
    end

    def available?
      true
    end

    def grab time, image_path
    end

    def available_formats
      ['png', 'tiff', 'bmp', 'mjpeg']
    end

    def to_s
      "Mock 1.0"
    end
  end
end
