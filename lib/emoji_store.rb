require 'redis'

class EmojiStore
  ROOT_KEY = "current_emooj"
  OLDEST_SET = ROOT_KEY + ":base"

  NoData = Class.new(StandardError)

  def initialize(redis)
    @redis = redis
  end

  def save(emoji)
    first_time_store(emoji) if first_time?
    @redis.mapped_hmset(store_key, emoji) unless @redis.exists(store_key)
  end

  def get_all(key=store_key)
    emooj = @redis.hgetall(key)
    emooj.empty? ? original : emooj
  end

  def new_since_last(new_set)
    diff get_all, new_set
  end

  def new_since_date(new_set, date)
    old_set = get_all(store_key(date))
    diff old_set, new_set
  end

  def original
    raise NoData, 'need to save some emoji data before attempting to fetch' if first_time?
    get_all(OLDEST_SET)
  end

  private

  def first_time?
    !@redis.exists(OLDEST_SET)
  end

  def first_time_store(emoji)
    @redis.mapped_hmset(OLDEST_SET, emoji)
  end

  def diff(old, new)
    added = new.keys - old.keys
    removed = old.keys - new.keys

    { added: diff_apply(new, added), removed: diff_apply(old, removed) }
  end

  def diff_apply(hash, selected)
    hash.select {|k, _v| selected.include? k }
  end

  def store_key(date=Date.today)
    "#{ROOT_KEY}:year:#{date.year}:week:#{date.cweek}"
  end
end
