#
# Configuration
#

require 'font'

module VCSRuby
  class Configuration
    attr_accessor :capturer
    attr_reader :header_font, :title_font, :timestamp_font, :signature_font

    def initialize
      default_config_file = File.expand_path("defaults.yml", File.dirname(__FILE__))
      local_config_files = ['~/.vcs.rb.yml']

      config = ::YAML::load_file(default_config_file)
      local_config_files.select{ |f| File.exists?(f) }.each do |local_config_file|
        puts "Local configuration file loaded: #{local_config_file}" if Tools.verbose?
        local_config = YAML::load_file(local_config_file)
        cconfig.merge(local_config)
      end

      @config = config

      @header_font    = Font.new @config['style']['header']['font'],    @config['style']['header']['size']
      @title_font     = Font.new @config['style']['title']['font'],     @config['style']['title']['size']
      @timestamp_font = Font.new @config['style']['timestamp']['font'], @config['style']['timestamp']['size']
      @signature_font = Font.new @config['style']['signature']['font'], @config['style']['signature']['size']
    end

    def rows
      @config['main']['rows'].to_i
    end

    def columns
      @config['main']['columns'].to_i
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

    def blank_threashold
      @config['lowlevel']['blank_threshold'].to_f
    end
  end
 end
