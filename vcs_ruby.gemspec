require File.expand_path("lib/version", File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = 'vcs_ruby'
  s.version     = VCSRuby::update_version
  s.date        = Date::today.to_s
  s.summary     = "Generates contact sheets of videos"
  s.description = "Creates a contact sheet, a preview, of a video, usable as library or as a script. Based on VCS *NIX. Creating Thumbnails with libav, ffmpeg or mplayer and compose it with ImageMagick into nice looking sheets."
  s.authors     = ["Thomas Bruderer"]
  s.email       = 'apophis@apophis.ch'
  s.files       = Dir['lib/*']
  s.bindir      = 'bin'
  s.executables << 'vcs.rb'
  s.test_files  = Dir['test/*.rb']
  s.homepage    = 'https://github.com/FreeApophis/vcs.rb'
  s.license       = 'GPL3'
  
  s.required_ruby_version = '>= 1.8.6'
  s.add_dependency 'mini_magick', '>= 4.0.0'
  s.requirements << 'libav or ffmpeg or mplayer'
end
