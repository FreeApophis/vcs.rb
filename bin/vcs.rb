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

options =
{
    :verbose => false,
}

arguments =
{
    "--capturer" => [:ffmpeg, :libav, :mplayer],
    "--format" => [:png, :jpeg],
}  

def list_arguments arguments
   arguments.map{ |argument| argument.to_s }.join(', ')
end


# Load config files

config_file, config = File.expand_path('../config.yml', __FILE__), {}
config = YAML.load_file(config_file) if File.exists?(config_file)

# Configuration can Override options
options = { interval: 300, quiet: true }.merge(config)

# Command Line Parameters
optparse = OptionParser.new do|opts| 
  opts.separator $vcs_ruby_name + ' ' + $vcs_ruby_version.to_s
  opts.separator ''
  opts.on( '-i [INTERVAL]', '--interval [INTERVAL]', 'Set the interval to arg in seconds') do |interval|
    options[:interval] = interval
  end
  opts.on( '-n [CAPS]', '--numcaps [CAPS]', 'Set the number of captured images to arg. Use either -i or -n') do |numcaps|
    options[:numcaps] = numcaps
  end
  opts.on( '-c [COLMNS]', '--columns [COLUMNS]', 'Arrange the output in <COLUMNS> columns.') do |columns|
    options[:columns] = columns
  end
  opts.on( '-r [ROWS]', '--rows [ROWS]', 'Arrange the output in <ROWS> rows.') do |rows|
    options[:rows] = rows
  end
  opts.on( '-h [HEIGHT]', '--height [HEIGHT]', 'Set the output (individual thumbnail) height.') do |height|
    options[:height] = height
  end
  opts.on( '-w [WIDTH]', '--width [WIDTH]', 'Set the output (individual thumbnail) width.') do |width|
    options[:width] = width
  end
  opts.on( '-a [ASPECT]', '--aspect [ASPECT]', 'Aspect ratio. Accepts a floating point number or a fraction.') do |aspect|
    options[:aspect] = aspect
  end
  opts.on( '-f [FROM]', '--from [FROM]', 'Set starting time. No caps before this.') do |from|
    options[:from] = from
  end
  opts.on( '-t [TO]', '--to [TO]', 'Set ending time. No caps beyond this.') do |to|
    options[:to] = to
  end
  opts.on( '-T [TITLE]', '--title [TITLE]', 'Set ending time. No caps beyond this.') do |title|
    options[:title] = title
  end
  opts.on( '-f [format]', '--format [FORMAT]', arguments['--format'], 'Formats: ' + list_arguments(arguments["--format"])) do |format|
    options[:format] = :jpg
  end
  opts.on('-C [CAPTURER]', '--capture [CAPTURER]', arguments['--capturer'], 'Capturer: ' + list_arguments(arguments["--capturer"])) do |capturer|
    options[:capturer] = capturer
  end
  opts.on( '-T [TITLE]', '--title [TITLE]', 'Set ending time. No caps beyond this.') do |title|
    options[:title] = title
  end
  opts.on( '-o [FILE]', '--output [FILE]', 'File name of output. When ommited will be derived from the input filename. Can be repeated for multiple files.') do |file|
    options[:output] = file
  end
  opts.on( '-s [SIGNATURE]', '--signature [SIGNATURE]', 'Image signature!') do |signature|
    options[:signature] = signature
  end
  opts.on( '-q', '--quiet', 'Don\'t print progress messages just errors. Repeat to mute completely, even on error.') do |file|
    options[:quiet] = true
  end
  opts.on( '-v', '--version', 'Version' ) do 
    puts $vcs_ruby_name + ' ' + $vcs_ruby_version.to_s
    exit 0 
  end 
  opts.on("-V", "--verbose", "Verbose Output") do
    options[:verbose] = true
  end
  
  opts.on( '-h', '--help', 'Prints help' ) do 
    options[:help] = true
  end 

  opts.separator ''
  opts.separator 'Examples:'
  opts.separator '  Create a contact sheet with default values (vidcaps at intervals of'
  opts.separator '  300 seconds), will be saved to "video.avi.png":'
  opts.separator '  $ vcs video.avi'
  opts.separator ''
  opts.separator '  Create a sheet with vidcaps at intervals of 3 and a half minutes, save to'
  opts.separator '  "output.jpg":'
  opts.separator '  $ vcs -i 3m30 input.wmv -o output.jpg'
  opts.separator ''
  opts.separator '  Create a sheet with vidcaps starting at 3 mins and ending at 18 mins,'
  opts.separator '  add an extra vidcap at 2m and another one at 19m:'
  opts.separator '  $ vcs -f 3m -t 18m -S2m -S 19m input.avi'
  opts.separator ''
  opts.separator '  See more examples at vcs-ruby homepage <>.'
  opts.separator ''
end

def print_help optparse
  puts optparse.summarize
  exit 0
end

print_help optparse if ARGV.empty?
  
optparse.parse!

print_help optparse if options[:help] || ARGV.empty?

def contact_sheet_with_options video, options
  VCSRuby::ContactSheet.new 'video.mkv' do
    sheet.rows = options[:rows] if options[:rows]
    sheet.columns = options[:columns] if options[:columns]

    sheet.thumbnail_width = options[:width] if options[:width]
    sheet.thumbnail_width = options[:width] if options[:width]
    sheet.thumbnail_height = options[:height] if options[:height]
  end
end

# Invoke ContactSheet

ARGV.each do |video|
  sheet = contact_sheet_with_options video, options
  sheet.create


  puts sheet.thumbnail_width
  puts sheet.thumbnail_height
  puts sheet.thumbnail_aspect
end

