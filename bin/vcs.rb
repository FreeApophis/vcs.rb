#!/usr/bin/ruby

# Video Contact Sheet Ruby: 
# ----------------------
#
# Generates contact sheets of videos
#
# Prerequisites: Ruby, ImageMagick, ffmpeg/libav or mplayer
#

# Load library path for development
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "../lib")

require 'optparse'
require 'vcs'

#result = RubyProf.profile do

last_arg = ARGV.last

options =
{
    :verbose => false,
}

arguments =
{
    "--capturer" => [:ffmpeg, :libav, :mplayer],
}  

o = OptionParser.new do |opts|
  opts.banner = "TODO"
  opts.on("-c", "--capturer TYPE", arguments["--capturer"], "Capturer: " + arguments["--capturer"].map{|a| a.to_s}.join(', ')) do |t|
    options[:type] = t
  end
  opts.on("-v", "--verbose", "Verbose Output") do
    options[:verbose] = true
  end

  opts.separator("")
  opts.separator("Example:")
  opts.separator("  vcs.rb video.mkv")
  opts.separator("")

end.parse!
