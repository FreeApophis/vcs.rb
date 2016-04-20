#
# Dependencies
#

module VCSRuby
  Command = Struct.new("Command", :name, :executable, :version, :available) do
    def windows?; false; end

    def parse_version param, regex
      @version = '0.0.0'

      if available
        m = regex.match(execute param)
        puts m.to_s if VCSRuby::Tools.verbose
        @version = m.captures.first if m
      end
    end

    def execute parameter
      raise "Command '#{:name}' not available" unless available
      if windows?
        `cmd /C #{executable}`
      else
        `#{executable} #{parameter} 2>/dev/null`
      end
    end
  end
 
  class Commands
    attr_reader :mplayer, :ffmpeg, :libav
    attr_reader :convert, :montage
    
    def initialize
       @software =
       {
           :mplayer => { :command => 'mplayer', :vparam => '', :vregex => /MPlayer svn (r\d*)/ } ,
           :ffmpeg => { :command => 'ffmpeg', :vparam => '-version', :vregex => /ffmpeg ([\d|.|-]*)/ } ,
           :libav => { :command => 'avconv', :vparam => '-version', :vregex => /avconv ([\d|.|-]*)/ } ,
           :convert => { :command => 'convert', :vparam => '-version', :vregex => /Version: ImageMagick ([\d|.|-]*)/ } ,
           :montage => { :command => 'montage', :vparam => '-version', :vregex => /Version: ImageMagick ([\d|.|-]*)/ } 

       }
       
       check_software
    end 

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which(cmd)
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      return nil
    end
    
    def check_software()
      @software.each_pair do |key, value|
        command = Struct::Command.new(key)

        exe = which(value[:command])
        command.executable = exe
        command.available = (exe != nil)
        command.parse_version value[:vparam], value[:vregex]

        
        instance_variable_set("@#{key.to_s}", command) if command.available
      end
    end
  end
end
