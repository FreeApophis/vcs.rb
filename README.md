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

* LibAV (implemented)
* FFMPEG (implemented)
* MPlayer (missing)

### Using with Paperclip, Carrierwave, Refile

Not yet tried. Any feedback welcome.

## Script

### Command Line Options

    Video Contact Sheet Ruby 0.8.0

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
        -l [HIGHLIGHT]Add the frame found at timestamp [HIGHLIGHT] as a highlight.,
            --highlight
        -q, --quiet                      Don't print progress messages just errors. Repeat to mute completely, even on error.
        -V, --verbose                    More verbose Output.
        -v, --version                    Version
        -h, --help                       Prints help

    Examples:
        Create a contact sheet with default values (4 x 4 matrix):
        $ vcs video.avi

        Create a sheet with vidcaps at intervals of 3 and a half minutes, save to
        "output.jpg":
        $ vcs -i 3m30 input.wmv -o output.jpg
