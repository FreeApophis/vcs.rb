require File.expand_path("lib/version", File.dirname(__FILE__))

Gem::Specification.new do |spec|
  spec.name        = 'vcs_ruby'
  spec.version     = VCSRuby::read_version
  spec.date        = Date::today.to_s
  spec.summary     = "Generates contact sheets of videos"
  spec.description = "Creates a contact sheet, a preview, of a video, usable as library or as a script. Based on VCS *NIX. Creating Thumbnails with libav, ffmpeg or mplayer and compose it with ImageMagick into nice looking sheets."
  spec.authors     = ["Thomas Bruderer"]
  spec.email       = 'apophis@apophis.ch'
  spec.files       = Dir['lib/**/*']
  spec.bindir      = 'bin'
  spec.executables << 'vcs.rb'
  spec.test_files  = Dir['test/*.rb']
  spec.homepage    = 'https://github.com/FreeApophis/vcs.rb'
  spec.license       = 'GPL3'

  spec.required_ruby_version = '>= 1.8.6'
  spec.add_dependency 'mini_magick', '~> 4.0', '>= 4.0.0'
  spec.requirements << 'libav or ffmpeg or mplayer'

  spec.add_development_dependency "bundler", '~> 1.5', '>= 1.5.0'
  spec.add_development_dependency "rake", '~> 11.0', '>= 11.0.0'
end
