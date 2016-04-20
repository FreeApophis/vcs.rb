#
# Dependencies
#

module VCSRuby
  Struct.new("Command", :name, :executable, :available)
 
  class Commands
    attr_reader :mplayer, :ffmpeg, :libav
    attr_reader :convert, :montage
    
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

    def capper
    end

    def execute
      if windows?
        version = `cmd /C `
      else
        version = ``
      end
    end
     
    def check_software()
      @software.each_pair do |key, value|
        command = Struct::Command.new(key)
        command.executable = value[:command]
        command.available = false
        
        instance_variable_set("@#{key.to_s}", command)
      end
    end
  end
end
