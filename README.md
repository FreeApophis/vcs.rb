# vcs.rb

Video Contact Sheet for Ruby

I do like the results of the "Video Contact Sheet *NIX" but the Script is written as a Shell Script and naturally this makes it hard to understand and extend.

vcs.rb has two main-scenarios in mind.

1.) It should be usable as a library in rails to make video captures easy.
2.) It should be usable as a simple script imitating the original vcs script.


Example

> require 'vcs.rb'
>
> sheet = VCSRuby::CaptureSheet.new 'video.mkv'

