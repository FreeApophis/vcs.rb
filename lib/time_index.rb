#
# Time interval
#

module VCSRuby
  class TimeIndex
    attr_reader :total_seconds

    def initialize time_interval_string = ''
      @total_seconds = 0.0 
      @to_parse = time_interval_string.strip

      unless @to_parse.empty?
        try_parse_ffmpeg_index
        try_parse_vcs_index
        try_parse_as_number
      end
    end

    def try_parse_ffmpeg_index
      parts = @to_parse.split(':')
      if parts.count == 3
        @total_seconds += parts[0].to_i * 60 * 60
        @total_seconds += parts[1].to_i * 60
        @total_seconds += parts[2].to_f
      end
    end

    def try_parse_vcs_index
      if @to_parse =~ /\d*m|\d*h|\d*s/
        parts = s.split(/(\d*h)|(\d*m)|(\d*s)/).select{|e| !e.empty?}
        parts.each do |part|
          add_vcs_part part
        end
      end
    end

    def add_vcs_part part
      @total_seconds += part.to_i * 60 * 60 if part.end_with? 'h'
      @total_seconds += part.to_i * 60 if part.end_with? 'm'
      @total_seconds += part.to_i
    end

    def try_parse_as_number
      temp = @to_parse.to_i
      if temp.to_s == @to_parse
        @total_seconds += temp
      end
    end


    def total_seconds
      @total_seconds
    end

    def hours
      (@total_seconds / 3600).to_i
    end

    def minutes
      ((@total_seconds / 60) % 60).to_i
    end

    def seconds
      @total_seconds % 60
    end

    def to_s
      "#{hours}h#{"%02d" % minutes}m#{"%02d" % seconds}s"
    end
  end
end
