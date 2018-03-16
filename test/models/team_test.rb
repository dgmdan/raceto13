require 'test_helper'

class TeamTest < ActiveSupport::TestCase
  test "should require name" do
    team = Team.new
    team.data_name = 'blah'
    assert_not team.save
  end

  test "should require data name" do
    team = Team.new
    team.name = 'blah'
    assert_not team.save
  end

end
