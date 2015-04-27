$LOAD_PATH.unshift "./lib"
require 'roda'
require './roda/plugins/emoji'

class App < Roda
  plugin :static, '/static'
  plugin :render,
         ext: "html.haml",
         engine: 'haml'
  plugin :emoji

  Slack.configure do |config|
    config.token = ENV.fetch('SLACK_TOKEN')
  end

  route do |r|
    r.root { r.redirect "/current" }

    r.on "current" do
      view 'emoji', locals: { emoji: cached_emoji.sort }
    end

    r.on "digest" do
      view 'digest', locals: { emoji: digest.sort }
    end
  end
end