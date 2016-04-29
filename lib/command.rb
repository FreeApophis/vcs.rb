#
# Command
#

module VCSRuby
  class Command
    attr_reader :name
    def initialize name, command
      @name = name
      @command = which(command)
      @available = !!@command
    end

    def available?
      @available
    end

    def execute parameter, streams = 0
      raise "Command '#{name}' not available" unless available?
      result = nil
      if Tools::windows?
        streams = '2> nul' if streams === 0
        
        result = `cmd /C #{@command} #{parameter} #{streams}`
      else
        streams = "2> /dev/null" if streams === 0
        
        result =`#{@command} #{parameter} #{streams}`
      end

      raise "#{@command} failed with return value '#{$?}'"unless $? == 0
      return result
    end
private
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which cmd
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
      return nil
    end
  end
 end
