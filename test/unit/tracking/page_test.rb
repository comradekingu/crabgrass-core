require 'test_helper'

class Tracking::PageTest < ActiveSupport::TestCase
  # otherwise transactions fail because UNLOCK TABLES implicitly commits the transaction
  self.use_transactional_fixtures = false

  def setup; end

  def test_group_view_tracked
    Tracking::Page.process
    user = users(:blue)
    group = groups(:rainbow)
    assert membership = user.memberships.find_by_group_id(group.id)
    assert_difference(format('group.memberships.find(%d).total_visits', membership.id)) do
      Tracking::Page.insert(current_user: user, group: group)
      Tracking::Page.process
    end
  end

  def test_user_visit_tracked
    current_user = users(:blue)
    user = users(:orange)

    assert_difference 'Tracking::Page.count', 3 do
      3.times { Tracking::Page.insert(current_user: current_user, user: user) }
    end
    assert_difference 'Tracking::Page.count', -3 do
      Tracking::Page.process
    end
    assert_equal 3, current_user.relationships.with(user).first.total_visits
  end

  def test_page_view_tracked_fully
    user = users(:blue)
    page = pages(:wiki) # id = 210
    group = groups(:rainbow)
    action = :view
    # let's clean things up first so they do not get in the way...
    Tracking::Page.process
    Tracking::Daily.update
    Tracking::Hourly.destroy_all
    assert_no_difference 'Tracking::Daily.count' do
      # daily should not be created for the new hourlies
      # we only create them with one day delay to avoid double counting.
      assert_difference 'Tracking::Hourly.count' do
        # 1, "hourly should be created for the tracked view" do
        assert_tracking(user, group, page, action)
        Tracking::Page.process
        Tracking::Daily.update
      end
    end
    # we create trackings for the day before yesterday here
    # - so they should be counted.
    # And we add another day for caution because Hourlies store the timestamp at the end
    # of the hour they were tracked in. So this will be on the next day in the hour
    # before midnight.
    assert_difference 'Tracking::Daily.count' do
      # Tracking::Hourly should be created for the tracked view
      # but then removed after being processed for daily.
      assert_no_difference 'Tracking::Hourly.count' do
        assert_tracking(user, group, page, action, Time.now - 3.days)
        Tracking::Page.process
        Tracking::Daily.update
      end
    end
  end

  private

  # Insert delayed is not delaysed for testing so this should not cause problems.
  def assert_tracking(user, group, page, action, time = nil)
    Tracking::Page.insert(current_user: user, group: group, page: page, action: action, time: time)
    track = Tracking::Page.last
    assert_equal track.current_user_id, user.id, 'User not stored correctly in Tracking'
    assert_equal track.group_id, group.id, 'Group not stored correctly in Tracking'
    assert_equal track.page_id, page.id, 'Page not stored correctly in Tracking'
    if action != :unstar
      assert_equal "#{action}s", %w[views edits stars].find { |a| Tracking::Page.last.send a },
                   'Tracking did not count the right action.'
      assert_equal 1, %w[views edits stars].select { |a| Tracking::Page.last.send a }.size,
                   'There shall be exactly one action counted.'
    else
      # TODO: check this before ActiveRecord gets in the way.
      assert_equal 0, %w[views edits stars].select { |a| Tracking::Page.last.send a }.size,
                   'For :unstar all values should evaluate to false.'
    end
  end
end
