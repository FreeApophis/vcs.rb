require 'minitest'
require 'vcs'

class VideoTest < Minitest::Test
  def setup
    VCSRuby::Configuration.instance.capturer = :mock
  end

  def test_video_basic_setup
    video = VCSRuby::Video.new 'mock.mpg'
    assert_equal :mock, video.capturer_name
    assert video.valid?
  end
end
