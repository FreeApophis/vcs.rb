#
# Dependencies
#

module VCSRuby
  class Tools
    def self.windows?
      return ((RUBY_PLATFORM =~ /win32/ or RUBY_PLATFORM =~ /mingw32/) or (RbConfig::CONFIG['host_os'] =~ /mswin|windows/i))
    end

    def self.linux?
      return ((RUBY_PLATFORM =~ /linux/) or (RbConfig::CONFIG['host_os'] =~ /linux/i))
    end

    def self.verbose= verbose
      @verbose = verbose
      @quiet = false if @verbose
    end

    def self.verbose?
      @verbose
    end

    def self.quiet= quiet
      @quiet = quiet
      @verbose = false if @quiet
    end

    def self.quiet?
      @quiet
    end

    def self.list_arguments arguments
      arguments.map{ |argument| argument.to_s }.join(', ')
    end

    def self.print_help optparse
      puts optparse.summarize
      exit 0
    end

    def self.contact_sheet_with_options video, options
      sheet = VCSRuby::ContactSheet.new video, options[:capturer]
      sheet.format = options[:format] if options[:format]
      sheet.title = options[:title] if options[:title]
      sheet.signature = options[:signature] if options[:signature]
      sheet.signature = nil if options[:no_signature]

      if options[:rows] || options[:columns] || options[:interval]
        sheet.initialize_geometry(options[:rows], options[:columns], options[:interval])
      end

      sheet.thumbnail_width = options[:width] if options[:width]
      sheet.thumbnail_height = options[:height] if options[:height]
      sheet.from = options[:from] if options[:from]
      sheet.to = options[:to] if options[:to]
      sheet.highlight = options[:highlight] if options[:highlight]

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
