class ChatChannel < ActiveRecord::Base
  self.table_name = 'channels'

  belongs_to :group
  validates_presence_of :group

  has_many :channels_users,
           dependent: :delete_all,
           class_name: 'ChatChannelsUser',
           foreign_key: 'channel_id'

  has_many :users, through: :channels_users

  has_many :messages, class_name: 'ChatMessage',
                      foreign_key: 'channel_id',
                      dependent: :delete_all do
    def since(last_seen_id)
      where('id > ?', last_seen_id).all
    end

    # returns an array of months that had messages for a particular channel
    def months
      return unless first
      sql = 'SELECT MONTH(messages.created_at) AS month, '
      sql += 'YEAR(messages.created_at) AS year FROM messages '
      sql += "WHERE channel_id = '#{first.channel_id}' AND #{conditions} "
      sql += 'GROUP BY year, month ORDER BY year, month'
      ChatMessage.connection.select_all(sql)
    end

    # returns an array with the days that had messages for a channel on a month
    def days(year, month)
      return unless first
      begin_date = Time.zone.local(year, month)
      end_date = begin_date.advance(months: 1)
      sql = 'SELECT DAY(messages.created_at) AS day FROM messages '
      sql += "WHERE channel_id = '#{first.channel_id}' AND #{conditions} "
      sql += "AND messages.created_at >= '#{begin_date.to_s(:db)}' "
      sql += "AND messages.created_at < '#{end_date.to_s(:db)}' "
      sql += 'GROUP BY day ORDER BY day'
      ChatMessage.connection.select_all(sql)
    end

    # get all messages for the channel on a day
    def for_day(year, month, day)
      begin_date = Time.zone.local(year, month, day)
      end_date = begin_date.advance(days: 1)
      conditions = "created_at >= '#{begin_date.to_s(:db)}' "
      conditions += "AND created_at < '#{end_date.to_s(:db)}'"
      where(conditions).all
    end
  end

  def self.cleanup!
    users_just_left = ChatChannelsUser.where('last_seen < DATE_SUB(?, INTERVAL 1 MINUTE) OR last_seen IS NULL', Time.now.utc.to_s(:db)).all
    users_just_left.each do |ex_user|
      ChatMessage.create(channel: ex_user.channel, sender: ex_user.user, content: I18n.t(:left_the_chatroom), level: 'sys')
      ex_user.destroy
    end
  end
end
