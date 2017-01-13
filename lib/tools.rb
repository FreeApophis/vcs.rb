#
# Various Tool Functions
#

module VCSRuby

  class Tools
    def self.windows?
      return ((RUBY_PLATFORM =~ /win32/ or RUBY_PLATFORM =~ /mingw32/) or (RbConfig::CONFIG['host_os'] =~ /mswin|windows/i))
    end

    def self.linux?
      return ((RUBY_PLATFORM =~ /linux/) or (RbConfig::CONFIG['host_os'] =~ /linux/i))
    end

    def self.list_arguments arguments
      arguments.map{ |argument| argument.to_s }.join(', ')
    end

    def self.print_help optparse
      puts optparse.summarize
      exit 0
    end

    MagickVersion = Struct.new(:major, :minor, :revision)
    def self.magick_version
      output = %x[convert -version]
      m = output.match(/(\d+)\.(\d+)\.(\d+)(-(\d+))?/)
      MagickVersion.new(m[1].to_i, m[2].to_i, m[3].to_i)
    end

    def self.contact_sheet_with_options video, options
      Configuration.instance.load_profile options[:profile] if options[:profile]
      Configuration.instance.capturer = options[:capturer]

      video = VCSRuby::Video.new video
      
      unless video.valid?
        puts "Video '#{video.full_path}' cannot be read by Capturer '#{video.capturer_name}'"
        return nil
      end
      
      sheet = video.contact_sheet

      sheet.format = options[:format] if options[:format]
      sheet.title = options[:title] if options[:title]
      sheet.signature = options[:signature] if options[:signature]
      sheet.signature = nil if options[:no_signature]

      if options[:rows] || options[:columns] || options[:interval]
        sheet.initialize_geometry(options[:rows], options[:columns], options[:interval])
      end

      if options[:width] && options[:height]
        sheet.aspect_ratio = Rational(options[:width], options[:height])
      else
        sheet.aspect_ratio = options[:aspect_ratio] if options[:aspect_ratio]      
      end
      sheet.thumbnail_width = options[:width] if options[:width]
      sheet.thumbnail_height = options[:height] if options[:height]
      sheet.from = options[:from] if options[:from]
      sheet.to = options[:to] if options[:to]
      sheet.highlight = options[:highlight] if options[:highlight]

      sheet.timestamp = options[:timestamp] if options[:timestamp] != nil
      sheet.softshadow = options[:softshadow] if options[:softshadow] != nil
      sheet.polaroid = options[:polaroid] if options[:polaroid] != nil

      return sheet
    end

    def self.to_human_size size
      powers = { 'B'  => 1 << 10, 'KiB' => 1 << 20, 'MiB' => 1 << 30, 'GiB' => 1 << 40, 'TiB' => 1 << 50 }
      powers.each_pair do |prefix, power|
        if size < power
          return format('%.2f',size.to_f / (power >> 10)) + ' ' + prefix
        end
      end
    end
  end
end
