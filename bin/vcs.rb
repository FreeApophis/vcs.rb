#!/usr/bin/env ruby

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
require 'yaml'

include VCSRuby


# Configuration can Override options
options =
{
             quiet: false,
           verbose: false,
          capturer: :any,
            format: nil,
            output: []
}

# Command Line Parameter arguments

arguments =
{
    '--capturer' => [:ffmpeg, :libav, :mplayer, :any],
    '--format' => [:png, :jpg, :jpeg, :tiff],
    '--funky' =>  [:polaroid, :photos, :overlap, :rotate, :photoframe, :polaroidframe, :film, :random]
}

# Command Line Parameters
optparse = OptionParser.new do|opts|
  opts.separator $vcs_ruby_name + ' ' + $vcs_ruby_version.to_s
  opts.separator ''
  opts.on( '-i [INTERVAL]', '--interval [INTERVAL]', 'Set the interval [INTERVAL]') do |interval|
    options[:interval] = TimeIndex.new interval
  end
  opts.on( '-c [COLMNS]', '--columns [COLUMNS]', 'Arrange the output in <COLUMNS> columns.') do |columns|
    options[:columns] = columns.to_i
  end
  opts.on( '-r [ROWS]', '--rows [ROWS]', 'Arrange the output in <ROWS> rows.') do |rows|
    options[:rows] = rows.to_i
  end
  opts.on( '-H [HEIGHT]', '--height [HEIGHT]', 'Set the output (individual thumbnail) height.') do |height|
    options[:height] = height.to_i
  end
  opts.on( '-W [WIDTH]', '--width [WIDTH]', 'Set the output (individual thumbnail) width.') do |width|
    options[:width] = width.to_i
  end
  opts.on( '-A [ASPECT]', '--aspect [ASPECT]', 'Aspect ratio. Accepts a floating point number or a fraction.') do |aspect|
    options[:aspect] = aspect.to_f
  end
  opts.on( '-f [FROM]', '--from [FROM]', 'Set starting time. No caps before this.') do |from|
    options[:from] = TimeIndex.new from
  end
  opts.on( '-t [TO]', '--to [TO]', 'Set ending time. No caps beyond this.') do |to|
    options[:to] = TimeIndex.new to
  end
  opts.on( '-T [TITLE]', '--title [TITLE]', 'Set ending time. No caps beyond this.') do |title|
    options[:title] = title
  end
  opts.on( '-f [format]', '--format [FORMAT]', arguments['--format'], 'Formats: ' + Tools::list_arguments(arguments["--format"])) do |format|
    options[:format] = format
  end
  opts.on('-C [CAPTURER]', '--capture [CAPTURER]', arguments['--capturer'], 'Capturer: ' + Tools::list_arguments(arguments["--capturer"])) do |capturer|
    options[:capturer] = capturer
  end
  opts.on( '-T [TITLE]', '--title [TITLE]', 'Set Title') do |title|
    options[:title] = title
  end
  opts.on( '-o [FILE]', '--output [FILE]', 'File name of output. When ommited will be derived from the input filename. Can be repeated for multiple files.') do |file|
    options[:output] << file
  end
  opts.on( '-s [SIGNATURE]', '--signature [SIGNATURE]', 'Change the image signature to your preference.') do |signature|
    options[:signature] = signature
  end
  opts.on( '--no-signature', 'Remove footer with signature') do
    options[:no_signature] = true
  end
  opts.on( '-l [HIGHLIGHT]', '--highlight [HIGHLIGHT]', 'Add the frame found at timestamp [HIGHLIGHT] as a highlight.') do |highlight|
    options[:highlight] = TimeIndex.new highlight
  end
  opts.on("--[no-]timestamp", "Add timestamp to thumbnails. Default: true") do |timestamp|
    options[:timestamp] = timestamp
  end
  opts.on("--[no-]shadow", "Add shadow to thumbnails. Default: true") do |shadow|
    options[:shadow] = shadow
  end
  opts.on("--[no-]polaroid", "Add  polaroid frame to thumbnail. Default: false") do |polaroid|
    options[:polaroid] = polaroid
  end
  opts.on( '-p [PROFILE]', '--profile [PROFILE]', 'Loads additional setting from profile.yml.') do |profile|
    options[:profile] = profile
  end
  opts.on( '-q', '--quiet', 'Don\'t print progress messages just errors.') do |file|
    options[:quiet] = true
  end
  opts.on('--continue', 'Prints Error message and continues with next file (if any left)') do |file|
    options[:continue] = true
  end
  opts.on("-V", "--verbose", "More verbose Output.") do
    options[:verbose] = true
  end
  opts.on( '-v', '--version', 'Current Version' ) do
    puts $vcs_ruby_name + ' ' + $vcs_ruby_version.to_s
    exit 0
  end

  opts.on( '-h', '--help', 'Prints help' ) do
    options[:help] = true
  end

  opts.separator ''
  opts.separator 'Examples:'
  opts.separator '  Create a contact sheet with default values (4 x 4 matrix):'
  opts.separator '  $ vcs video.avi'
  opts.separator ''
  opts.separator '  Create a sheet with vidcaps at intervals of 3 and a half minutes, save to'
  opts.separator '  "output.jpg":'
  opts.separator '  $ vcs -i 3m30 input.wmv -o output.jpg'
  opts.separator ''
  opts.separator '  Create a sheet with vidcaps starting at 3 mins and ending at 18 mins in 2m intervals'
  opts.separator '  $ vcs --from 3m --to 18m -i 2m input.avi'
  opts.separator ''
  opts.separator '  See more examples at vcs-ruby homepage <https://github.com/FreeApophis/vcs.rb>.'
  opts.separator ''
end

Tools::print_help optparse if ARGV.empty?

optparse.parse!

Tools::print_help optparse if options[:help] || ARGV.empty?

Configuration.instance.verbose = options[:verbose]
Configuration.instance.quiet = options[:quiet]

# Invoke ContactSheet

errors = {}
ARGV.each_with_index do |video, index|
  begin
    sheet = Tools::contact_sheet_with_options video, options
    sheet.initialize_filename(options[:output][index]) if options[:output][index]
    sheet.build
  rescue Exception => e
    errors[video] = e
    STDERR.puts "ERROR: #{e.message}"
    STDERR.puts "#{e.backtrace.join("\n")}" if options[:verbose]
    break unless options[:continue]
  end
end

if options[:continue] && errors.length > 0
  errors.each do |video, e|
    STDERR.puts "File: #{video}"
    STDERR.puts "ERROR: #{e.message}"
 end
 STDERR.puts "Total: #{errors.length} Errors"
end
