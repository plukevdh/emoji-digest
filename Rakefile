require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << ["test", "lib"]
  t.pattern = "test/**/*_test.rb"
end

namespace :emoji do
  desc 'Collect and store the current emoji set'
  task :collect do
    require './app'

    _redis_url = ENV['REDIS_URL'] || ENV['REDISTOGO_URL']

    begin
      harvester = EmojiHarvester.new Slack.client
      store = EmojiStore.new Redis.new(url: _redis_url)

      emoji = harvester.harvest
      store.save(emoji)
    rescue EmojiHarvester::APIError => e
      puts e.message
    end
  end
end

task :default => [:test]
