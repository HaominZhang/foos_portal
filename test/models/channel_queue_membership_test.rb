require 'test_helper'

class ChannelQueueMembershipTest < ActiveSupport::TestCase
  def test_validates_presence_of_channel_queue
    channel_queue_membership = ChannelQueueMembership.new(user: User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500))
    assert_not_predicate channel_queue_membership, :valid?

    channel_queue_membership.channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')
    assert_predicate channel_queue_membership, :valid?
  end

  def test_validates_presence_of_user
    channel_queue_membership = ChannelQueueMembership.new(channel_queue: ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234'))
    assert_not_predicate channel_queue_membership, :valid?

    channel_queue_membership.user = User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500)
    assert_predicate channel_queue_membership, :valid?
  end

  def test_validates_uniqueness_of_user_and_channel
    channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')
    user = User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500)

    ChannelQueueMembership.create!(channel_queue: channel_queue, user: user)

    invalid_queue_membership = ChannelQueueMembership.new(channel_queue: channel_queue, user: user)
    assert_not_predicate invalid_queue_membership, :valid?

    different_user_queue_membership = ChannelQueueMembership.new(channel_queue: channel_queue, user: User.create!(slack_user_id: '2', slack_user_name: 'different', rank: 1500))
    assert_predicate different_user_queue_membership, :valid?

    different_channel_queue_membership = ChannelQueueMembership.new(channel_queue: ChannelQueue.create!(slack_channel_name: 'different', slack_channel_id: 'U1235'), user: user)
    assert_predicate different_channel_queue_membership, :valid?
  end

  def test_belongs_to_channel_queue
    channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')
    user = User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500)

    channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: user)

    assert_equal channel_queue, channel_queue_membership.channel_queue
  end

  def test_belongs_to_user
    channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')
    user = User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500)

    channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: user)

    assert_equal user, channel_queue_membership.user
  end

  def test_active__expire_after_7am
    channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')

    expiry_time = Time.now.in_time_zone('Pacific Time (US & Canada)').beginning_of_day + 7.hours

    old_channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500), created_at: expiry_time - 1.hour)
    borderline_channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: User.create!(slack_user_id: '2', slack_user_name: 'jane', rank: 1500), created_at: expiry_time)
    new_channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: User.create!(slack_user_id: '3', slack_user_name: 'eartha', rank: 1500), created_at: expiry_time + 1.hour)

    assert_equal [borderline_channel_queue_membership, new_channel_queue_membership], ChannelQueueMembership.active
  end

  def test_active__expire_after_7am__empty
    channel_queue = ChannelQueue.create!(slack_channel_name: 'ev-chargers-of-appfolio', slack_channel_id: 'U1234')

    expiry_time = Time.now.in_time_zone('Pacific Time (US & Canada)').beginning_of_day + 7.hours

    old_channel_queue_membership = ChannelQueueMembership.create!(channel_queue: channel_queue, user: User.create!(slack_user_id: '1', slack_user_name: 'joe', rank: 1500), created_at: expiry_time - 1.hour)

    assert_empty ChannelQueueMembership.active
  end
end