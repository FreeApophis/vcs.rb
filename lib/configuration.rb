#
# Configuration
#

require 'font'
require 'singleton'

class ::Hash
    def deep_merge(second)
        merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        self.merge(second, &merger)
    end
end

module VCSRuby
  class Configuration
    include Singleton
    
    attr_reader :header_font, :title_font, :timestamp_font, :signature_font
    attr_writer :verbose, :quiet

    def initialize
      default_config_file = File.expand_path("defaults.yml", File.dirname(__FILE__))
      @config = ::YAML::load_file(default_config_file)

      local_config_files = ['~/.vcs.rb.yml']
      local_config_files.select{ |f| File.exists?(f) }.each do |local_config_file|
        puts "Local configuration file loaded: #{local_config_file}" if Tools.verbose?
        local_config = YAML::load_file(local_config_file)
        @config = @config.deep_merge(local_config)
      end

      @header_font    = Font.new @config['style']['header']['font'],    @config['style']['header']['size']
      @title_font     = Font.new @config['style']['title']['font'],     @config['style']['title']['size']
      @timestamp_font = Font.new @config['style']['timestamp']['font'], @config['style']['timestamp']['size']
      @signature_font = Font.new @config['style']['signature']['font'], @config['style']['signature']['size']
    end

    def load_profile profile
      profiles = [File.expand_path("#{profile}.yml", File.dirname(__FILE__)), "~/#{profile}.yml"]

      found = false
      profiles.each do |profile|
        if File.exists?(profile)
          puts "Profile loaded: #{profile}" if Tools.verbose?
          config = YAML::load_file(profile)
          @config = @config.deep_merge(config)
          found = true
        end
      end

      raise "No profile '#{profile}' found" unless found
    end

    def verbose?
      @verbose
    end

    def quiet?
      @quiet
    end
    
    def capturer
      @capturer || :any
    end
    
    def rows
      @config['main']['rows'] ? @config['main']['rows'].to_i : nil
    end

    def columns
      @config['main']['columns'] ? @config['main']['columns'].to_i : nil
    end

    def interval
      @config['main']['interval'] ? TimeIndex.new(@config['main']['interval']) : nil
    end

    def padding
      @config['main']['padding'] ? @config['main']['padding'].to_i : 2
    end

    def quality
      @config['main']['quality'] ? @config['main']['quality'].to_i : 90
    end

    def header_background
      @config['style']['header']['background']
    end

    def header_color
      @config['style']['header']['color']
    end

    def title_background
      @config['style']['title']['background']
    end

    def title_color
      @config['style']['title']['color']
    end

    def highlight_background
      @config['style']['highlight']['background']
    end

    def contact_background
      @config['style']['contact']['background']
    end

    def timestamp_background
      @config['style']['timestamp']['background']
    end

    def timestamp_color
      @config['style']['timestamp']['color']
    end

    def signature_background
      @config['style']['signature']['background']
    end

    def signature_color
      @config['style']['signature']['color']
    end

    def blank_threshold
      @config['lowlevel']['blank_threshold'].to_f
    end

    def blank_evasion?
      @config['lowlevel']['blank_evasion']
    end

    def blank_alternatives
      @config['lowlevel']['blank_alternatives'].map{ |e| TimeIndex.new e.to_i }
    end

    def timestamp
      !!@config['filter']['timestamp']
    end

    def polaroid
      !!@config['filter']['polaroid']
    end

    def softshadow
      !!@config['filter']['softshadow']
    end
  end
 end
