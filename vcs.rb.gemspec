require File.expand_path("lib/version", File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'vcs.rb'
  s.version     = VCSRuby::update_version
  s.date        = '2016-04-19'
  s.summary     = "Generates contact sheets of videos"
  s.description = "Creates a contact sheet of a video, usable as library or as a script. Based on VCS *NIX"
  s.authors     = ["Thomas Bruderer"]
  s.email       = 'apophis@apophis.ch'
  s.files       = Dir['lib/*']
  s.bindir      = 'bin'
  s.executables << 'vcs.rb'
  s.test_files  = Dir['test/*.rb']
  s.homepage    = 'https://github.com/FreeApophis/vcs.rb'
  s.license       = 'GPL3'
  
  s.required_ruby_version = '>= 1.8.6'
  s.requirements << 'libmagick'
  s.requirements << 'ffmpeg, libav or mplayer'
end
