#
# Dependencies
#

module VCSRuby
  class Tools
    def self.windows?
      false
    end

    def self.verbose= verbose
      @verbose = verbose
    end

    def self.verbose
      @verbose
    end

    def self.list_arguments arguments
      arguments.map{ |argument| argument.to_s }.join(', ')
    end

    def self.print_help optparse
      puts optparse.summarize
      exit 0
    end

    def self.contact_sheet_with_options video, options
      sheet = VCSRuby::ContactSheet.new video
      sheet.capturer = options[:capturer]

      sheet.rows = options[:rows] if options[:rows]
      sheet.columns = options[:columns] if options[:columns]

      sheet.thumbnail_width = options[:width] if options[:width]
      sheet.thumbnail_height = options[:height] if options[:height]

      sheet
    end
  end
end
