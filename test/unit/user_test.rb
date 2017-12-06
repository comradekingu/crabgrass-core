require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    Time.zone = ActiveSupport::TimeZone['Pacific Time (US & Canada)']
  end

  def test_user_fixtures_are_valid
    orange = users(:orange)
    orange.valid?
    assert_equal({}, orange.errors.messages)
    assert orange.valid?
  end

  def test_user_factories_create_passwords
    user = FactoryBot.create :user
    refute_nil user.password_digest
  end

  def test_email_required_settings
    assert !User.new.should_validate_email
    orange = users(:orange)
    orange.email = nil
    orange.valid?
    assert_equal({}, orange.errors.messages)
    assert orange.valid?
  end

  def test_ensure_values_in_receive_notifications
    user = FactoryBot.create(:user)

    user.receive_notifications = nil
    user.save!
    assert_nil user.receive_notifications

    user.receive_notifications = true
    user.save!
    assert_nil user.receive_notifications

    user.receive_notifications = false
    user.save!
    assert_nil user.receive_notifications

    user.receive_notifications = 'Any'
    user.save!
    assert_nil user.receive_notifications

    user.receive_notifications = 'Digest'
    user.save!
    assert_equal 'Digest', user.receive_notifications

    user.receive_notifications = 'Single'
    user.save!
    assert_equal 'Single', user.receive_notifications

    user.receive_notifications = ''
    user.save!
    assert_nil user.receive_notifications
  end

  ## ensure that a user and a group cannot have the same handle
  def test_namespace
    assert_no_difference 'User.count' do
      u = FactoryBot.build :user, login: 'groups'
      assert !u.valid?
      assert u.errors[:login]
    end

    g = Group.create name: 'robot-overlord'
    assert_no_difference 'User.count' do
      u = FactoryBot.build :user, login: 'robot-overlord'
      assert !u.valid?
      assert u.errors[:login]
    end
  end

  def test_associations
    assert check_associations(User)
  end

  def test_alphabetized
    assert_equal User.count, User.alphabetized('').size

    # find numeric group names
    assert_equal 0, User.alphabetized('#').size
    FactoryBot.create :user, login: '2unlimited', password: '3qasdb43!sdaAS...', password_confirmation: '3qasdb43!sdaAS...'
    assert_equal 1, User.alphabetized('#').size

    # case insensitive
    assert_equal User.alphabetized('G').size, User.alphabetized('g').size

    # nothing matches
    assert User.alphabetized('z').empty?
  end

  def test_peers_of
    u = users(:blue)
    assert_equal u.peers, User.peers_of(u)
  end

  def test_friends_or_peers_with_access
    red = users(:red)
    blue = users(:blue)

    assert !red.access?(red.associated(:friends) => :spy), 'this test assumes that friends cannot spy by default'

    red.grant_access!(blue => :spy)
    red.add_contact!(blue)

    with_access = User.with_access(blue => :spy).friends_or_peers_of(blue)
    assert_equal ['red'], with_access.to_a.map(&:login)
  end

  def test_changing_display_name_pushes_group
    red = users(:red)
    rainbow = groups(:rainbow)

    assert_difference 'rainbow.reload.version', 2 do
      assert_no_difference 'rainbow.reload.updated_at' do
        red.display_name = 'rojo'
        red.save
      end
    end
  end

  def test_changing_display_name_increments_version
    red = users(:red)

    assert_difference 'red.reload.version', 3 do
      red.display_name = 'rojo'
      red.save
    end
  end

  #
  # creating users no longer adds keys
  #
  # def test_user_creation_adds_keys
  #  assert_difference 'Key.count', 3 do
  #    user = User.make
  #  end
  # end
end
