require 'test_helper'

describe EmojiStore do
  let(:fake_redis) { Minitest::FireMock.new("Redis") }
  let(:store) { EmojiStore.new fake_redis }
  let(:fake_key) { 'current_emooj:year:2015:week:12' }

  let(:emoots) {{
    wat: "http://a-url.com/img.jpg",
    two: "http://two.com/dot.png"
  }}

  describe "saving new set" do
    it "can store emoji symbols" do
      store.stub :store_key, fake_key do
        fake_redis.expect(:exists, true, [store.class::OLDEST_SET])
        fake_redis.expect(:exists, false, [fake_key])
        fake_redis.expect(:mapped_hmset, true, [fake_key, emoots])

        assert store.save(emoots), "expected save to succeed"

        fake_redis.verify
      end
    end

    it "also saves original if first time" do
      store.stub :store_key, fake_key do
        fake_redis.expect(:exists, false, [store.class::OLDEST_SET])
        fake_redis.expect(:mapped_hmset, true, [store.class::OLDEST_SET, emoots])
        fake_redis.expect(:exists, false, [fake_key])
        fake_redis.expect(:mapped_hmset, true, [fake_key, emoots])

        assert store.save(emoots), "expected save to succeed"

        fake_redis.verify
      end
    end

    it "does not save emojiset if exists (idempotent)" do
      store.stub :store_key, fake_key do
        fake_redis.expect(:exists, true, [store.class::OLDEST_SET])
        fake_redis.expect(:exists, true, [fake_key])

        assert_nil store.save(emoots)

        fake_redis.verify
      end
    end
  end

  it "can retrieve emoji symbols" do
    store.stub :store_key, fake_key do
      fake_redis.expect(:hgetall, emoots, [fake_key])
      store.get_all

      fake_redis.verify
    end
  end

  it "raises error if trying to retrieve with no prior data" do
    store.stub :store_key, fake_key do
      fake_redis.expect(:hgetall, {}, [fake_key])
      fake_redis.expect(:exists, false, [store.class::OLDEST_SET])

      assert_raises EmojiStore::NoData do
        store.get_all
      end

      fake_redis.verify
    end
  end

  it "can diff the new set and return new" do
    store.stub :store_key, fake_key do
      fake_redis.expect(:hgetall, emoots, [fake_key])

      new_set = emoots.merge(hey: 'http://com.com/dawg.png', facebool: "http://facebool.com/mine.png")
      new_set.delete(:wat)

      assert_equal({added: [:hey, :facebool], removed: [:wat]}, store.new_since_last(new_set))
      fake_redis.verify
    end
  end


  describe "historical" do
    let(:date) { Date.new(2008,8,1) }
    it "can compare from specific date" do
      fake_redis.expect(:hgetall, emoots, ['current_emooj:year:2008:week:31'])
      new_set = emoots.merge(hey: 'http://com.com/dawg.png')

      assert_equal({added: [:hey], removed: []}, store.new_since_date(new_set, date))
      fake_redis.verify
    end

    it "uses oldest set for dates with no historical data" do
      fake_redis.expect(:hgetall, {}, ['current_emooj:year:2008:week:31'])
      fake_redis.expect(:exists, true, [store.class::OLDEST_SET])
      fake_redis.expect(:hgetall, emoots, [store.class::OLDEST_SET])

      assert_equal({added: [], removed: []}, store.new_since_date(emoots, date))
      fake_redis.verify
    end
  end

end
