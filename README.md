# vcs_ruby

Video Contact Sheet for Ruby

[![Gem Version](https://badge.fury.io/rb/vcs_ruby.png)](https://badge.fury.io/rb/vcs_ruby)
[![Build Status](https://travis-ci.org/FreeApophis/vcs.rb.svg?branch=master)](https://travis-ci.org/FreeApophis/vcs.rb)

I do like the results of the "[Video Contact Sheet *NIX](http://p.outlyer.net/vcs/)" but the Script is written as a Shell Script and naturally this makes it hard to understand and extend.

vcs.rb has two main-scenarios in mind.

1. It should be usable as a library in rails to make video captures easy.
2. It should be usable as a simple script imitating the original vcs script.


![Example 1](https://raw.githubusercontent.com/FreeApophis/vcs.rb/master/example/ons3on3cup.png)


## Code Example

```ruby
  require 'vcs.rb'

  sheet = VCSRuby::CaptureSheet.new 'video.mkv'

  sheet.format = :jpg
  sheet.sheet.initialize_geometry(3,3,nil)
  sheet.signature = nil
  sheet.thumbnail_width = 320
  sheet.initialize_filename('out.jpg')
 
  sheet.build
```

# Help

## Installation

    gem install vcs_ruby

## Library

You will only need the CaptureSheet class from the VCSRuby Module. All other classes are only helper classes to create a Capture Sheet easily for you.

The library uses MiniMagick to use ImageMagick and we use directly libav, ffmpeg or mplayer whatever you have on your System.

### Capturer

To extract the images from the videos you can select your preferred capturer. Currently there are the following 3 options:

* LibAV
* FFMPEG
* MPlayer

### Using with Paperclip, Carrierwave, Refile

Not yet tried. Any feedback welcome.

## Script

### Command Line Options

    Video Contact Sheet Ruby 1.0.0

        -i, --interval [INTERVAL]        Set the interval [INTERVAL]
        -c, --columns [COLUMNS]          Arrange the output in <COLUMNS> columns.
        -r, --rows [ROWS]                Arrange the output in <ROWS> rows.
        -H, --height [HEIGHT]            Set the output (individual thumbnail) height.
        -W, --width [WIDTH]              Set the output (individual thumbnail) width.
        -A, --aspect [ASPECT]            Aspect ratio. Accepts a floating point number or a fraction.
            --from [FROM]                Set starting time. No caps before this.
        -t, --to [TO]                    Set ending time. No caps beyond this.
        -f, --format [FORMAT]            Formats: png, jpg, jpeg, tiff
        -C, --capture [CAPTURER]         Capturer: ffmpeg, libav, mplayer, any
        -T, --title [TITLE]              Set ending time. No caps beyond this.
        -o, --output [FILE]              File name of output. When ommited will be derived from the input filename. Can be repeated for multiple files.
        -s, --signature [SIGNATURE]      Change the image signature to your preference.
            --no-signature               Remove footer with signature
        -l, --highlight [HIGHLIGHT]      Add the frame found at timestamp [HIGHLIGHT] as a highlight.
            --[no-]timestamp             Add timestamp to thumbnails. Default: true
            --[no-]shadow                Add shadow to thumbnails. Default: true
            --[no-]polaroid              Add  polaroid frame to thumbnail. Default: false
        -p, --profile [PROFILE]          Loads additional setting from profile.yml.
        -q, --quiet                      Don't print progress messages just errors.
        -V, --verbose                    More verbose Output.
        -v, --version                    Current Version
        -h, --help                       Prints help

    Examples:
      Create a contact sheet with default values (4 x 4 matrix):
      $ vcs video.avi

      Create a sheet with vidcaps at intervals of 3 and a half minutes, save to
      "output.jpg":
      $ vcs -i 3m30 input.wmv -o output.jpg

      Create a sheet with vidcaps starting at 3 mins and ending at 18 mins in 2m intervals
      $ vcs --from 3m --to 18m -i 2m input.avi

### Profiles

Each Profile is a yml file which copies all or parts of the defaults.yml file to overwrite some part of the settings.

There are a few profiles delivered with the gem. [black, white, oldstyle]

    twobytwo.yml

This Profile Makes a two by two contact sheet with a large 10px padding and red text on yellow background for the header part. Place this file directly into the <home> dir and call it with --profile twobytwo

    main:
      rows: 2
      columns: 2
      interval: ~
      padding: 10
    style:
      header:
        color: Red
        background: "#ffcc00"

### All Profile Settings

Options | Default | Description
------- | ------- | -----------
main:rows: | 4 | Number of Rows
main:columns: | 4 | Number of Columns
main:interval: | ~ | Number of columns, default is ~ (nil)
main:padding: | 2 | Padding in pixels | around thumbnail
main:quality | 95 | quality level [1-100] for jpeg images
filter:timestamp | true | Add a timestamp to the thumbnail
filter:polaroid | true | Add a polaroid frame to the thumbnail
filter:softshadow | true | Add a shadow to the thumbanil
style:header:font | DejaVuSans.ttf | font (name or file) for the header 
style:header:size | 14 | Size of the font for the header
style:header:color | Black | Color of the text for the header
style:header:background | #afcd7a | Background color for the header
style:title:font | DejaVuSans.ttf | font (name or file) for the title 
style:title:size | 33 | Size of the font for the title
style:title:color | Black | Color of the text for the title
style:title:background | White | Background color for the title
style:highlight:background | SlateGray | Background color for the highlight 
style:contact:background | SlateGray | Background color for the contact sheet
style:timestamp:font | DejaVuSans.ttf | font (name or file) for the timestamp 
style:timestamp:size | 14 | Size of  the font for the timestamp
style:timestamp:color | White | Color of the text for the timestamp
style:timestamp:background | #000000aa |  Background color for the timestamp
style:signature:font | DejaVuSans.ttf | font (name or file) for the signature
style:signature:size | 10 | Size of the font for the signature
style:signature:color | Black | Color of the text for the signature
style:signature:background | SlateGray | Background color for the signature
lowlevel:blank_evasion | true | try to avoid blank frames
lowlevel:blank_threshold | 0.10 | median image brightness
lowlevel:blank_alternatives | [ -5, 5, -10, 10, -30, 30] | Array of seconds around interval
