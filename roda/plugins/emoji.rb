require 'emoji_store'
require 'emoji_harvester'

class Roda
  module RodaPlugins
    module Emoji
      module InstanceMethods
        def current_emoji
          harvester.harvest
        end

        def cached_emoji
          storage.get_all
        end

        def digest
          storage.new_since_last(current_emoji)
        end

        def digest_since(date)
          storage.new_since_date(current_emoji, date)
        end

        private

        def storage
          @_store ||= EmojiStore.new(redis)
        end

        def harvester
          @_harvester ||= EmojiHarvester.new(Slack.client)
        end

        def redis
          @_redis ||= begin
            _redis_url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL']
            Redis.new(url: _redis_url)
          end
        end
      end
    end

    register_plugin :emoji, Emoji
  end
end
