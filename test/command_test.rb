require 'minitest'
require 'vcs'

class CommandTest < Minitest::Test
  def test_command
    command = VCSRuby::Command.new 'test_find', 'find'

    assert_equal 'test_find', command.name
    assert command.available?, 'Command find not found'

    command.execute '--help'
  end
end
