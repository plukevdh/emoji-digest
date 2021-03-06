require 'emoji_store'
require 'emoji_harvester'

class Roda
  module RodaPlugins
    module Emoji

      def self.configure(app, options: {})
        app.opts[:redis] = Redis.new url: (options[:redis_url] || ENV['REDIS_URL'] || ENV['REDISTOGO_URL'])
      end

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

        def random(count)
          items = cached_emoji
          count = count ? count.to_i : 4

          random_keys = items.keys.sample(count)

          Hash[random_keys.zip(items.values_at(*random_keys))]
        end

        private

        def storage
          @_store ||= EmojiStore.new(opts[:redis])
        end

        def harvester
          @_harvester ||= EmojiHarvester.new(Slack.client)
        end
      end
    end

    register_plugin :emoji, Emoji
  end
end
