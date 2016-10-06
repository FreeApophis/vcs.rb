#
# Represents a stream in a video
#

require 'vcs'

module VCSRuby
  class Stream
    def initialize stream
      @stream = stream
      create_accessors
    end
    
    def create_accessors
      @stream.each do |key, value|
        self.class.send :define_method, key.to_sym do
          return @stream[key]
        end
      end
    end
    
    private
  end
end
