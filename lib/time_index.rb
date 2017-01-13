#
# Time interval
#

module VCSRuby
  class TimeIndex
    include Comparable
    attr_reader :total_seconds

    def initialize time_index = ''
      if time_index.instance_of? Float or time_index.instance_of? Fixnum
        @total_seconds = time_index
      else
        @total_seconds = 0.0
        @to_parse = time_index.strip

        unless @to_parse.empty?
          try_parse_ffmpeg_index
          try_parse_vcs_index
          try_parse_as_number
        end
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
        parts = @to_parse.split(/(\d*h)|(\d*m)|(\d*s)/).select{|e| !e.empty?}
        parts.each do |part|
          add_vcs_part part
        end
      end
    end

    def add_vcs_part part
      return @total_seconds += part.to_i * 60 * 60 if part.end_with? 'h'
      return @total_seconds += part.to_i * 60 if part.end_with? 'm'
      @total_seconds += part.to_i
    end

    def try_parse_as_number
      temp = @to_parse.to_f
      if temp.to_s == @to_parse
        @total_seconds += temp
      end
    end

    def hours
      (@total_seconds.abs / 3600).to_i
    end

    def minutes
      ((@total_seconds.abs / 60) % 60).to_i
    end

    def seconds
      @total_seconds.abs % 60
    end

    def + operand
      if operand.instance_of? Fixnum
        TimeIndex.new @total_seconds + operand
      else
        TimeIndex.new @total_seconds + operand.total_seconds
      end
    end

    def - operand
      if operand.instance_of? Fixnum
        TimeIndex.new @total_seconds - operand
      else
        TimeIndex.new @total_seconds - operand.total_seconds
      end
    end

    def * operand
      TimeIndex.new total_seconds * operand
    end

    def / operand
      if operand.instance_of? Fixnum
        TimeIndex.new @total_seconds / operand
      else
        @total_seconds / operand.total_seconds
      end
    end

    def <=> operand
      @total_seconds <=> operand.total_seconds
    end

    def sign
      return '-' if @total_seconds < 0
      ''
    end

    def to_s
      "#{sign}#{hours}h#{"%02d" % minutes}m#{"%02d" % seconds}s"
    end

    def to_timestamp
      if hours == 0
        "#{sign}#{"%02d" % minutes}:#{"%02d" % seconds}"
      else
        "#{sign}#{hours}:#{"%02d" % minutes}:#{"%02d" % seconds}"
      end
    end
  end
end
