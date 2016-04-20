#
# Version of vcs.rb
#

module VCSRuby
  def self.version_path
    File.expand_path("version.info", File.dirname(__FILE__))
  end

  def self.read_version
    File.open(version_path, &:readline)
  end

  def self.update_version
    parts = File.open(version_path, &:readline).split('.').map(&:strip)
    parts[2] = (parts[2].to_i + 1).to_s
    File.open(version_path, 'w') {|f| f.write(parts.join('.')) }

    $vcs_ruby_version
  end
end

$vcs_ruby_version = Gem::Version.new(VCSRuby::read_version)
$vcs_ruby_name = 'Video Contact Sheet Ruby'
$vcs_ruby_short = 'vcr.rb'
