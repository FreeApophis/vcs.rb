#
# Dependencies
#

module VCSRuby
 Struct.new("Program", :name, :executable, :available)
 
  class Dependency
    attr_reader :mplayer, :ffmpeg, :libav, :convert, :montage
    
    def initialize
       @software =
       {
           :mplayer => { :command => 'mplayer' },
           :ffmpeg => { :command => 'ffmpeg' },
           :libav => { :command => 'mplayer' },
           :convert => { :command => 'convert' },
           :montage => { :command => 'montage' }
           
       }
       
       check_software
    end 
    
    def windows?
      false
    end
     
    def check_software()
      
      @software.each_pair do |key, value|
        program = Struct::Program.new(key)
        program.executable = value[:command]
        program.available = false
        
        instance_variable_set("@#{key.to_s}", program)
      end
    end
  end
end
