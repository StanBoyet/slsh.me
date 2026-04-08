require "test_helper"

class VisitTest < ActiveSupport::TestCase
  test "human scope excludes bots" do
    link = links(:active_link)
    assert_includes Visit.human, visits(:human_visit)
    assert_not_includes Visit.human, visits(:bot_visit)
  end

  test "bots scope excludes humans" do
    assert_includes Visit.bots, visits(:bot_visit)
    assert_not_includes Visit.bots, visits(:human_visit)
  end
end
