require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << ["test", "lib"]
  t.pattern = "test/**/*_test.rb"
end


namespace :emoji do
  desc 'Collect and store the current emoji set'
  task :collect do
    require './app'

    begin
      harvester = EmojiHarvester.new Slack.client
      store = EmojiStore.new Redis.new(url: ENV.fetch('REDIS_URL'))

      emoji = harvester.harvest
      store.save(emoji)
    rescue EmojiHarvester::APIError => e
      puts e.message
    end
  end
end