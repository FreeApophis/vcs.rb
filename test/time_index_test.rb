require 'minitest'
require 'vcs'

class TimeIndexTest < Minitest::Test
  def test_simple_initialisation
    time = VCSRuby::TimeIndex.new 60

    assert_equal 60, time.total_seconds
  end

  def test_valid_ffmpeg_parse
    time = VCSRuby::TimeIndex.new '00:59:59'

    assert_equal 3599, time.total_seconds
  end

  def test_valid_comma_ffmpeg_parse
    time = VCSRuby::TimeIndex.new '01:09:59.13'

    assert_equal 4199.13, time.total_seconds
    assert_equal 1, time.hours
    assert_equal 9, time.minutes
    assert_equal 59, time.seconds.to_i
  end

  def test_invalid_ffmpeg_parse
    time = VCSRuby::TimeIndex.new '59:59'

    assert_equal 0, time.total_seconds
  end

  def test_valid_vcs_parse
    time = VCSRuby::TimeIndex.new '5m'

    assert_equal 300, time.total_seconds
  end

  def test_complex_vcs_parse
    time = VCSRuby::TimeIndex.new '1h 5m 17s'

    assert_equal 3917, time.total_seconds
    assert_equal 1, time.hours
    assert_equal 5, time.minutes
    assert_equal 17, time.seconds
  end

  def test_invalid_string_parse
    time = VCSRuby::TimeIndex.new 'invalid'

    assert_equal 0, time.total_seconds
  end

  def test_valid_string_parse
    time = VCSRuby::TimeIndex.new '55.55'

    assert_equal 55.55, time.total_seconds
  end

  def test_multiply
    time = VCSRuby::TimeIndex.new '1m 13s'
    five = time * 5

    assert_equal "0h06m05s", five.to_s
  end

  def test_addition
    time1 = VCSRuby::TimeIndex.new '1m 13s'
    time2 = VCSRuby::TimeIndex.new 3600
    total = time1 + time2

    assert_equal "1:01:13", total.to_timestamp
  end

  def test_valid_substraction
    time = VCSRuby::TimeIndex.new '3h 17m'
    total = time - 20000

    assert_equal "-2h16m20s", total.to_s
  end
end
